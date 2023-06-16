import fastapi as _fastapi
from fastapi.middleware.cors import CORSMiddleware
import services as _services, schemas as _schemas
import sqlalchemy.orm as _orm
import fastapi.security as _security
from typing import List


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
    db_lender = _services.get_lender_by_email(db=db, email=borrower.email)
    if db_borrower or db_lender:
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


@app.patch("/update_borrower_patch/", response_model=_schemas.BorrowerPatch)
def update_borrower_patch(
    m: _schemas.BorrowerPatch,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
):
    return _services.patch_borrower(db=db, borrower=borrower, m=m)


@app.post("/riwayat/", response_model=_schemas.Riwayat)
def create_riwayat(
    riwayat: _schemas.RiwayatCreate,
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.create_riwayat(db=db, riwayat=riwayat, borrower=borrower)


@app.post("/riwayatLender/", response_model=_schemas.RiwayatLender)
def create_riwayat_lender(
    riwayat: _schemas.RiwayatLenderCreate,
    lender: _schemas.Lender = _fastapi.Depends(_services.get_current_lender),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.create_riwayat_lender(db=db, riwayat=riwayat, lender=lender)


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


@app.get("/borrower/riwayat/", response_model=List[_schemas.Riwayat])
def get_borrower_riwayat(
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_current_borrower_riwayat(db=db, borrower=borrower)


@app.post("/lenders/")
def create_lender(
    lender: _schemas.LenderCreate,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    db_borrower = _services.get_borrower_by_email(db=db, email=lender.email)
    db_lender = _services.get_lender_by_email(db=db, email=lender.email)
    if db_lender or db_borrower:
        raise _fastapi.HTTPException(status_code=400, detail="email already use")

    user = _services.create_lender(db=db, lender=lender)
    return _services.create_token_lender(lender=user)


@app.post("/lender/token/")
def generate_token_lender(
    form_data: _security.OAuth2PasswordRequestForm = _fastapi.Depends(),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    lender = _services.authenticate_lender(
        email=form_data.username, password=form_data.password, db=db
    )
    if not lender:
        raise _fastapi.HTTPException(status_code=401, detail="Invalid Credentials")

    return _services.create_token_lender(lender=lender)


@app.get("/lender/me/", response_model=_schemas.Lender)
def get_lender(
    lender: _schemas.Lender = _fastapi.Depends(_services.get_current_lender),
):
    return lender


@app.post("/riwayatLender/", response_model=_schemas.RiwayatLender)
def create_riwayat_lender(
    riwayat: _schemas.RiwayatLenderCreate,
    lender: _schemas.Lender = _fastapi.Depends(_services.get_current_lender),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.create_riwayat_lender(db=db, riwayat=riwayat, lender=lender)


@app.get("/lender/riwayat/", response_model=List[_schemas.RiwayatLender])
def get_lender_riwayat(
    lender: _schemas.Lender = _fastapi.Depends(_services.get_current_lender),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_current_lender_riwayat(db=db, lender=lender)


@app.get("/borrower/market/", response_model=_schemas.Market)
def get_borrower_market(
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_current_borrower_market(db=db, borrower=borrower)


@app.get("/borrower/ajuan/", response_model=_schemas.Ajuan)
def get_borrower_ajuan(
    borrower: _schemas.Borrower = _fastapi.Depends(_services.get_current_borrower),
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_current_borrower_ajuan(db=db, borrower=borrower)


@app.patch("/update_lender_patch/", response_model=_schemas.LenderPatch)
def update_lender_patch(
    m: _schemas.LenderPatch,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
    lender: _schemas.Lender = _fastapi.Depends(_services.get_current_lender),
):
    return _services.patch_lender(db=db, lender=lender, m=m)


@app.patch("/update_market_patch/{id}", response_model=_schemas.MarketPatch)
def update_market_patch(
    id: int,
    m: _schemas.MarketPatch,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.patch_market(db=db, m=m, id=id)


@app.get("/markets/", response_model=List[_schemas.Market])
def get_markets(
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_markets(db=db)


# @app.get("/umkm/{ajuan_id}", response_model=_schemas.Umkm)
# def get_umkm_by_market(
#     ajuan_id: int,
#     db: _orm.Session = _fastapi.Depends(_services.get_db),
# ):
#     return _services.get_umkm_by_market(db=db, ajuan_id=ajuan_id)


@app.get("/ajuan/{ajuan_id}", response_model=_schemas.Ajuan)
def get_ajuan_by_ajuan_id(
    ajuan_id: int,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_ajuan_by_ajuan_id(db=db, ajuan_id=ajuan_id)


@app.get("/borrower/{ajuan_id}", response_model=_schemas.Borrower)
def get_borrower_by_ajuan_id(
    ajuan_id: int,
    db: _orm.Session = _fastapi.Depends(_services.get_db),
):
    return _services.get_borrower_by_ajuan_id(db=db, ajuan_id=ajuan_id)
