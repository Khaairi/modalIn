import fastapi as _fastapi
from fastapi.middleware.cors import CORSMiddleware
import services as _services, schemas as _schemas
import sqlalchemy.orm as _orm
import fastapi.security as _security

app = _fastapi.FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

_services.create_database()


@app.post("/borrowers/")
def create_borrower(
    borrower: _schemas.BorrowerCreate,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    db_borrower = _services.get_borrower_by_email(db=db, email=borrower.email)
    if db_borrower:
        raise _fastapi.HTTPException(status_code=400, detail="email already use")

    user = _services.create_borrower(db=db, borrower=borrower)
    return _services.create_token(borrower=user)


@app.post("/borrower/token/")
def generate_token(
    form_data: _security.OAuth2PasswordRequestForm = _fastapi.Depends(),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    borrower = _services.authenticate_borrower(
        email=form_data.username, password=form_data.password, db=db
    )
    if not borrower:
        raise _fastapi.HTTPException(status_code=401, detail="Invalid Credentials")

    return _services.create_token(borrower=borrower)


@app.get("/borrower/me/", response_model=_schemas.Borrower)
def get_borrower(
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
):
    return borrower


@app.delete("/borrowers/delete/{borrower_id}")
def delete_borrower(
    borrower_id: int, db: _orm.Session = _fastapi.Depends(_services.get_db)
):
    _services.delete_borrower(db=db, borrower_id=borrower_id)
    return {"message": f"successfully deleted borrower with id: {borrower_id}"}


@app.post("/umkm/", response_model=_schemas.Umkm)
def create_umkm(
    umkm: _schemas.UmkmCreate,
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.create_umkm(db=db, umkm=umkm, borrower=borrower)


@app.delete("/umkm/delete/{umkm_id}")
def delete_umkm(umkm_id: int, db: _orm.Session = _fastapi.Depends(_services.get_db)):
    _services.delete_umkm(db=db, umkm_id=umkm_id)
    return {"message": f"successfully deleted umkm with id: {umkm_id}"}


# @app.post("/borrowers/login/", response_model=_schemas.Borrower)
# def login_borrower(
#     borrower: _schemas.BorrowerLogin,
#     db: _orm.Session = _fastapi.Depends(_services.get_db),
# ):
#     db_borrower = _services.get_borrower_login(db=db, borrower=borrower)
#     if db_borrower is None:
#         raise _fastapi.HTTPException(
#             status_code=404, detail="sorry this user does not exist"
#         )
#     elif db_borrower == "password salah":
#         raise _fastapi.HTTPException(status_code=405, detail="password incorrect")
#     return db_borrower


# @app.get("/borrowers/{borrower_id}")
# def get_borrower_by_id(
#     borrower_id: int, db: _orm.Session = _fastapi.Depends(_services.get_db)
# ):
#     db_borrower = _services.get_borrower_by_id(db=db, borrower_id=borrower_id)
#     if db_borrower is None:
#         raise _fastapi.HTTPException(
#             status_code=404, detail="sorry this user does not exist"
#         )
#     return db_borrower


@app.patch("/update_borrower_patch/", response_model=_schemas.BorrowerPatch)
def update_borrower_patch(
    m: _schemas.BorrowerPatch,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
):
    try:  # Replace with your database URL
        existing_borrower = _services.get_borrower_by_id(db=db, borrower_id=borrower.id)

        if existing_borrower:
            if m.nama != "kosong":
                existing_borrower.nama = m.nama
            if m.email != "kosong":
                existing_borrower.email = m.email
            if m.password != "kosong":
                existing_borrower.password = m.password
            if m.saku != -9999:
                existing_borrower.saku = m.saku
            # if m.id != -9999:
            #     existing_borrower.id = m.id
            if m.telp != "kosong":
                existing_borrower.telp = m.telp
            if m.status != "kosong":
                existing_borrower.status = m.status
            # if m.ktp != "kosong":
            #     existing_borrower.ktp = m.ktp

            if m.status == "diterima":
                existing_ajuan = _services.get_ajuan_by_id(
                    db=db, borrower_id=existing_borrower.id
                )
                _services.create_market(
                    ajuan=existing_ajuan, db=db, market=_schemas.MarketCreate
                )

            db.commit()
            db.refresh(existing_borrower)
            # response.headers["location"] = "/mahasixswa/{}".format(id)
        else:
            raise _fastapi.HTTPException(status_code=404, detail="Item Not Found")

    except Exception as e:
        raise _fastapi.HTTPException(
            status_code=500, detail="Terjadi exception: {}".format(str(e))
        )

    return m


@app.post("/riwayat/", response_model=_schemas.Riwayat)
def create_riwayat(
    riwayat: _schemas.RiwayatCreate,
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.create_riwayat(db=db, riwayat=riwayat, borrower=borrower)


@app.post("/ajuan/", response_model=_schemas.Ajuan)
def create_ajuan(
    ajuan: _schemas.AjuanCreate,
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.create_ajuan(db=db, ajuan=ajuan, borrower=borrower)


@app.delete("/ajuan/delete/{ajuan_id}")
def delete_ajuan(ajuan_id: int, db: _orm.Session = _fastapi.Depends(_services.get_db)):
    _services.delete_ajuan(db=db, ajuan_id=ajuan_id)
    return {"message": f"successfully deleted ajuan with id: {ajuan_id}"}


# @app.get("/borrowers/login/", response_model=_schemas.Borrower)
# def login_borrower(
#     email: str,
#     password: str,
#     db: _orm.Session = _fastapi.Depends(_services.get_db),
# ):
#     db_borrower = _services.get_borrower_login(db=db, email=email, password=password)
#     if db_borrower is None:
#         raise _fastapi.HTTPException(
#             status_code=404, detail="sorry this user does not exist"
#         )
#     elif db_borrower == "password salah":
#         raise _fastapi.HTTPException(status_code=405, detail="password incorrect")
#     return db_borrower
