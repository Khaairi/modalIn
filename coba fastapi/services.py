import database as _database, models as _models, schemas as _schemas
import sqlalchemy.orm as _orm
import passlib.hash as _hash
import jwt as _jwt
import fastapi as _fastapi
import fastapi.security as _security
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta

_JWT_SECRET = "thisisnotverysafe"
oauth2schema = _security.OAuth2PasswordBearer("/borrower/token/")


def create_database():
    return _database.Base.metadata.create_all(bind=_database.engine)


def get_db():
    db = _database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_borrower_by_email(db: _orm.Session, email: str):
    return db.query(_models.Borrower).filter(_models.Borrower.email == email).first()


def get_borrower_by_id(db: _orm.Session, borrower_id: int):
    return db.query(_models.Borrower).filter(_models.Borrower.id == borrower_id).first()


def create_borrower(db: _orm.Session, borrower: _schemas.BorrowerCreate):
    hashed_password = _hash.bcrypt.hash(borrower.password)
    db_borrower = _models.Borrower(
        nama=borrower.nama,
        email=borrower.email,
        password=hashed_password,
        telp=borrower.telp,
        ktp=borrower.ktp,
        saku=borrower.saku,
        status=borrower.status,
    )
    db.add(db_borrower)
    db.commit()
    db.refresh(db_borrower)
    return db_borrower


def create_token(borrower: _models.Borrower):
    borrower_schema_obj = _schemas.Borrower.from_orm(borrower)
    borrower_dict = borrower_schema_obj.dict()

    expires = datetime.utcnow() + timedelta(
        minutes=60
    )  # Example: Token expires in 1 hour
    borrower_dict["exp"] = expires

    token = _jwt.encode(borrower_dict, _JWT_SECRET)
    return dict(access_token=token, token_type="bearer")


def authenticate_borrower(email: str, password: str, db: _orm.Session):
    borrower = get_borrower_by_email(email=email, db=db)

    if not borrower:
        return False

    if not borrower.verify_password(passwords=password):
        return False

    return borrower


def get_current_borrower(
    db: _orm.Session = _fastapi.Depends(get_db),
    token: str = _fastapi.Depends(oauth2schema),
):
    try:
        payload = _jwt.decode(token, _JWT_SECRET, algorithms=["HS256"])
        borrower = db.query(_models.Borrower).get(payload["id"])
    except:
        raise _fastapi.HTTPException(
            status_code=401, detail="Email Atau Password Salah"
        )

    return _schemas.Borrower.from_orm(borrower)


# def get_borrower_login(db: _orm.Session, borrower: _schemas.BorrowerLogin):
#     db_borrower = get_borrower_by_email(db=db, email=borrower.email)
#     if db_borrower is not None:
#         if db_borrower.password != borrower.password:
#             db_borrower = "password salah"

#     return db_borrower


# def get_borrower_login(db: _orm.Session, email: str, password: str):
#     db_borrower = get_borrower_by_email(db=db, email=email)
#     if db_borrower is not None:
#         if db_borrower.password != password:
#             db_borrower = "password salah"
#     return db_borrower


def delete_borrower(db: _orm.Session, borrower_id: int):
    db.query(_models.Borrower).filter(_models.Borrower.id == borrower_id).delete()
    db.commit()


def create_umkm(
    db: _orm.Session, umkm: _schemas.UmkmCreate, borrower: _schemas.Borrower
):
    db_umkm = _models.Umkm(
        nama=umkm.nama,
        alamat=umkm.alamat,
        kategori=umkm.kategori,
        penghasilan=umkm.penghasilan,
        fotoUmkm=umkm.fotoUmkm,
        npwp=umkm.npwp,
        dokumen=umkm.dokumen,
        borrower_id=borrower.id,
    )
    db.add(db_umkm)
    db.commit()
    db.refresh(db_umkm)
    return _schemas.Umkm.from_orm(db_umkm)


def delete_umkm(db: _orm.Session, umkm_id: int):
    db.query(_models.Umkm).filter(_models.Umkm.id == umkm_id).delete()
    db.commit()


def create_riwayat(
    db: _orm.Session, riwayat: _schemas.RiwayatCreate, borrower: _schemas.Borrower
):
    db_riwayat = _models.RiwayatBorrower(
        borrower_id=borrower.id,
        nominal=riwayat.nominal,
        status=riwayat.status,
    )
    db.add(db_riwayat)
    db.commit()
    db.refresh(db_riwayat)
    return db_riwayat


def create_ajuan(
    db: _orm.Session, ajuan: _schemas.AjuanCreate, borrower: _schemas.Borrower
):
    db_ajuan = _models.Ajuan(
        besar_biaya=ajuan.besar_biaya,
        tenor_pendanaan=ajuan.tenor_pendanaan,
        minimal_biaya=ajuan.minimal_biaya,
        opsi_pengembalian=ajuan.opsi_pengembalian,
        status=ajuan.status,
        bunga=ajuan.bunga,
        borrower_id=borrower.id,
    )
    db.add(db_ajuan)
    db.commit()
    db.refresh(db_ajuan)
    return db_ajuan


def delete_ajuan(db: _orm.Session, ajuan_id: int):
    db.query(_models.Ajuan).filter(_models.Ajuan.id == ajuan_id).delete()
    db.commit()


def get_ajuan_by_id(db: _orm.Session, borrower_id: int):
    return (
        db.query(_models.Ajuan)
        .filter(
            _models.Ajuan.borrower_id == borrower_id
            and _models.Ajuan.status == "mengajukan"
        )
        .first()
    )


def create_market(
    db: _orm.Session, market: _schemas.MarketCreate, ajuan: _schemas.Ajuan
):
    tenor = ajuan.tenor_pendanaan
    tenggat = datetime.now() + relativedelta(months=tenor)
    db_market = _models.Market(
        ajuan_id=ajuan.id,
        sisa_pendanaan=0,
        tenggat_pendanaan=tenggat,
        status="penggalangan",
    )
    db.add(db_market)
    db.commit()
    db.refresh(db_market)
    return db_market
