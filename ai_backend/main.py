from fastapi import FastAPI, UploadFile, File
import uvicorn

app = FastAPI()

@app.post("/api/v1/process-damaged-image")
async def process_damaged_image(file: UploadFile = File(...)):
    print(f"Resim alındı: {file.filename}")
    
    return {
        "status": "success",
        "decoded_data": "https://ornek-yapay-zeka-sonucu.com",
        "message": "Hasarlı QR kod yapay zeka ile başarıyla onarıldı."
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
