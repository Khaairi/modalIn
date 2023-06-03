from typing import List
import datetime as _dt
import pydantic as _pydantic


class _UmkmBase(_pydantic.BaseModel):
    nama: str
    alamat: str
    kategori: str
    penghasilan: int
    fotoUmkm: str
    npwp: str
    dokumen: str
    borrower_id: int


class UmkmCreate(_UmkmBase):
    pass


class Umkm(_UmkmBase):
    id: int

    class Config:
        orm_mode = True


class _BorrowerBase(_pydantic.BaseModel):
    nama: str
    email: str
    telp: str
    ktp: str
    saku: int


class BorrowerCreate(_BorrowerBase):
    password: str


class BorrowerLogin(_pydantic.BaseModel):
    email: str
    password: str


class Borrower(_BorrowerBase):
    id: int
    umkm: List[Umkm] = []

    class Config:
        orm_mode = True


class BorrowerPatch(_pydantic.BaseModel):
    nama: str = "kosong"
    email: str = "kosong"
    telp: str = "kosong"
    saku: int = -9999
    password: str = "kosong"
    # ktp : str = "kosong"
    # id : int = -9999
