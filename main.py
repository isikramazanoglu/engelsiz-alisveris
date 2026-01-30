from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import Optional, List
import shutil
import os

app = FastAPI()

# --- AYARLAR ---
os.makedirs("static", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

# --- VERİ MODELİ ---
class Product(BaseModel):
    name: str
    price: float
    barcode: str
    weight: str
    description: Optional[str] = None
    image_url: Optional[str] = None

# --- 50 ADETLİK MARKET VERİTABANI ---
fake_product_db = [
    # --- RESİMLİ İLK 5 ÜRÜN ---
    {"name": "Çaykur Rize Turist Çayı", "price": 145.00, "barcode": "8690637060017", "weight": "500gr", "description": "Geleneksel lezzet", "image_url": "http://127.0.0.1:8000/static/cay.jpg"},
    {"name": "Torku Tam Yağlı Süt", "price": 34.50, "barcode": "8690120060007", "weight": "1L", "description": "Pastörize süt", "image_url": "http://127.0.0.1:8000/static/sut.jpg"},
    {"name": "Coca-Cola Original", "price": 45.00, "barcode": "5449000000996", "weight": "1L", "description": "Gazlı içecek", "image_url": "http://127.0.0.1:8000/static/kola.jpg"},
    {"name": "Ülker Çikolatalı Gofret", "price": 6.75, "barcode": "8690504060236", "weight": "36gr", "description": "Çıtır gofret", "image_url": "http://127.0.0.1:8000/static/gofret.jpg"},
    {"name": "Uno Tost Ekmeği", "price": 55.00, "barcode": "8690605021019", "weight": "670gr", "description": "Dilimli ekmek", "image_url": "http://127.0.0.1:8000/static/ekmek.jpg"},

    # --- RESİMSİZ DİĞER ÜRÜNLER ---
    {"name": "Eti Cin Portakallı", "price": 8.50, "barcode": "8690526008513", "weight": "25gr"},
    {"name": "Nescafe 3ü1 Arada", "price": 5.00, "barcode": "8690632025820", "weight": "17gr"},
    {"name": "Erikli Su", "price": 12.00, "barcode": "8690562000298", "weight": "1.5L"},
    {"name": "SuperFresh Pizza King", "price": 120.00, "barcode": "8690574201829", "weight": "780gr"},
    {"name": "Solo Tuvalet Kağıdı", "price": 210.00, "barcode": "8690530136271", "weight": "32'li"},
    {"name": "Fairy Bulaşık Deterjanı", "price": 85.00, "barcode": "8001090382759", "weight": "1.5L"},
    {"name": "Barilla Spaghetti", "price": 32.00, "barcode": "8076809513753", "weight": "500gr"},
    {"name": "Nutella Fındık Kreması", "price": 115.00, "barcode": "8000500179864", "weight": "400gr"},
    {"name": "Lay's Klasik Cips", "price": 40.00, "barcode": "8690624101341", "weight": "150gr"},
    {"name": "Domestos Çamaşır Suyu", "price": 65.00, "barcode": "8690637172529", "weight": "750ml"},
    {"name": "Ruffles Peynir Soğan", "price": 40.00, "barcode": "8690624201348", "weight": "150gr"},
    {"name": "Doritos Taco", "price": 40.00, "barcode": "8690624301345", "weight": "150gr"},
    {"name": "Pınar Labne", "price": 45.00, "barcode": "8690547012345", "weight": "400gr"},
    {"name": "İçim Kaşar Peyniri", "price": 180.00, "barcode": "8690547056789", "weight": "700gr"},
    {"name": "Aytaç Dana Sucuk", "price": 250.00, "barcode": "8690547098765", "weight": "500gr"},
    {"name": "Maret Sosis", "price": 90.00, "barcode": "8690547043210", "weight": "250gr"},
    {"name": "Filiz Burgu Makarna", "price": 18.50, "barcode": "8690574205555", "weight": "500gr"},
    {"name": "Tat Domates Salçası", "price": 65.00, "barcode": "8690574206666", "weight": "830gr"},
    {"name": "Yudum Ayçiçek Yağı", "price": 195.00, "barcode": "8690574207777", "weight": "5L"},
    {"name": "Komili Sızma Zeytinyağı", "price": 450.00, "barcode": "8690574208888", "weight": "2L"},
    {"name": "Söke Un", "price": 35.00, "barcode": "8690574209999", "weight": "2kg"},
    {"name": "Bal Küpü Şeker", "price": 42.00, "barcode": "8690123456789", "weight": "1kg"},
    {"name": "Çaykur Tiryaki Çayı", "price": 135.00, "barcode": "8690637060024", "weight": "500gr"},
    {"name": "Lipton Yellow Label", "price": 150.00, "barcode": "8690637060031", "weight": "100'lü"},
    {"name": "Doğuş Earl Grey", "price": 45.00, "barcode": "8690637060048", "weight": "48'li"},
    {"name": "Beypazarı Maden Suyu", "price": 6.00, "barcode": "8690637060055", "weight": "200ml"},
    {"name": "Sırma Su", "price": 5.00, "barcode": "8690637060062", "weight": "500ml"},
    {"name": "Hayat Su", "price": 15.00, "barcode": "8690637060079", "weight": "5L"},
    {"name": "Colgate Diş Macunu", "price": 75.00, "barcode": "8690637060086", "weight": "75ml"},
    {"name": "Ipana Diş Macunu", "price": 65.00, "barcode": "8690637060093", "weight": "75ml"},
    {"name": "Oral-B Diş Fırçası", "price": 50.00, "barcode": "8690637060109", "weight": "1 adet"},
    {"name": "Head & Shoulders Şampuan", "price": 110.00, "barcode": "8690637060116", "weight": "400ml"},
    {"name": "Pantene Şampuan", "price": 105.00, "barcode": "8690637060123", "weight": "400ml"},
    {"name": "Elidor Saç Kremi", "price": 85.00, "barcode": "8690637060130", "weight": "350ml"},
    {"name": "Nivea Deodorant", "price": 95.00, "barcode": "8690637060147", "weight": "150ml"},
    {"name": "Rexona Deodorant", "price": 90.00, "barcode": "8690637060154", "weight": "150ml"},
    {"name": "Gillette Tıraş Köpüğü", "price": 80.00, "barcode": "8690637060161", "weight": "200ml"},
    {"name": "Permatik Banyo", "price": 45.00, "barcode": "8690637060178", "weight": "5'li"},
    {"name": "Selpak Kağıt Havlu", "price": 120.00, "barcode": "8690637060185", "weight": "6'lı"},
    {"name": "Familia Tuvalet Kağıdı", "price": 190.00, "barcode": "8690637060192", "weight": "32'li"},
    {"name": "Vernel Yumuşatıcı", "price": 75.00, "barcode": "8690637060208", "weight": "1.5L"},
    {"name": "Omo Matik", "price": 220.00, "barcode": "8690637060215", "weight": "5kg"},
    {"name": "Pril Bulaşık Deterjanı", "price": 45.00, "barcode": "8690637060222", "weight": "750ml"},
    {"name": "Cif Krem", "price": 55.00, "barcode": "8690637060239", "weight": "500ml"},
    {"name": "Ace Çamaşır Suyu", "price": 40.00, "barcode": "8690637060246", "weight": "1L"},
]

shopping_cart = []
favorites_db = [] # Favoriler burada tutulacak ❤️

@app.get("/")
def home():
    return {"message": "Engelsiz Market API vFinal - Tüm Özellikler Aktif 🚀"}

@app.get("/product/{barcode_id}")
def get_product(barcode_id: str):
    for product in fake_product_db:
        if product["barcode"] == barcode_id:
            return product
    raise HTTPException(status_code=404, detail="Ürün bulunamadı")

@app.post("/cart/add/{barcode_id}")
def add_to_cart(barcode_id: str):
    found_product = None
    for product in fake_product_db:
        if product["barcode"] == barcode_id:
            found_product = product
            break
    if not found_product:
        raise HTTPException(status_code=404, detail="Ürün yok")
    shopping_cart.append(found_product)
    return {"message": f"{found_product['name']} sepete eklendi", "cart_size": len(shopping_cart)}

@app.get("/cart")
def view_cart():
    total = sum(item["price"] for item in shopping_cart)
    return {"items": shopping_cart, "total": total}

@app.post("/upload-image/")
async def upload_image(file: UploadFile = File(...)):
    file_location = f"static/{file.filename}"
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    return {"info": "Resim yüklendi", "url": f"http://127.0.0.1:8000/static/{file.filename}"}

# --- YENİ EKLENEN FAVORİ ÖZELLİĞİ ---
@app.post("/favorites/add/{barcode_id}")
def add_favorite(barcode_id: str):
    # Ürün zaten favoride mi kontrol et
    for item in favorites_db:
        if item["barcode"] == barcode_id:
             return {"message": "Bu ürün zaten favorilerde ekli!"}

    # Ürünü bul
    found_product = None
    for product in fake_product_db:
        if product["barcode"] == barcode_id:
            found_product = product
            break
    
    if not found_product:
        raise HTTPException(status_code=404, detail="Ürün bulunamadı")

    # Favorilere ekle
    favorites_db.append(found_product)
    return {"message": f"{found_product['name']} favorilere eklendi ❤️"}

@app.get("/favorites")
def get_favorites():
    return {"favorites": favorites_db, "count": len(favorites_db)}