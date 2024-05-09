from fastapi import FastAPI
from pydantic import BaseModel

class Production(BaseModel):
    production_type: str = None
    thaw_time: int
    lead_days: int
    short_name: str

class Item(BaseModel):
    description: str = None
    production: Production


app = FastAPI()


@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

@app.post("/items/")
def create_item(item: Item):
    # Logic to create item
    return item

@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    # Logic to update item
    return {"item_id": item_id, "item": item}

@app.delete("/items/{item_id}")
def delete_item(item_id: int):
    # Logic to delete item
    return {"item_id": item_id}