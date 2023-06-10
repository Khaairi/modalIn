from typing import List
import datetime as _dt
import pydantic as _pydantic
from pydantic import Field
from typing import Optional


class _UmkmBase(_pydantic.BaseModel):
    nama: str
    alamat: str
    kategori: str
    penghasilan: int
    fotoUmkm: str
    npwp: str
    dokumen: str


class UmkmCreate(_UmkmBase):
    pass


class Umkm(_UmkmBase):
    id: int
    borrower_id: int

    class Config:
        orm_mode = True


class _BorrowerBase(_pydantic.BaseModel):
    nama: str
    email: str
    telp: str
    ktp: str
    saku: int
    status: str


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
    status: str = "kosong"


class _RiwayatBase(_pydantic.BaseModel):
    nominal: int
    status: str


class RiwayatCreate(_RiwayatBase):
    pass


class Riwayat(_RiwayatBase):
    id: int
    borrower_id: int
    created_at: _dt.datetime

    class Config:
        orm_mode = True


class _AjuanBase(_pydantic.BaseModel):
    besar_biaya: int
    tenor_pendanaan: int
    minimal_biaya: int
    opsi_pengembalian: str
    bunga: int
    status: str


class AjuanCreate(_AjuanBase):
    pass


class Ajuan(_AjuanBase):
    id: int
    borrower_id: int
    # status : str
    # tenggat_pengembalian : _dt.datetime
    # bunga : int

    # status: Optional[str] = Field(None, nullable=True)
    tenggat_pengembalian: Optional[_dt.datetime] = Field(None, nullable=True)
    # bunga: Optional[int] = Field(None, nullable=True)

    class Config:
        orm_mode = True


class _MarketBase(_pydantic.BaseModel):
    ajuan_id: int
    waktu_acc: _dt.datetime
    sisa_pendanaan: int
    tenggat_pendanaan: _dt.datetime
    status: str


class MarketCreate(_MarketBase):
    pass


class Market(_MarketBase):
    id: int

    class Config:
        orm_mode = True
