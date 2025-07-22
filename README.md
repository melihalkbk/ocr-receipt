# Receipt OCR Web

🧾 **Receipt OCR Web**  
A modern Flutter Web application that lets you upload receipt images (market, restaurant, etc.), automatically extracts products and prices using OCR, and provides categorized spending analytics and summaries.

---

## Features

- 📸 **Upload Receipt Image:** Upload a photo of your receipt and extract text automatically with OCR.
- 🛒 **Product & Price Parsing:** Automatically detects products, prices, total amount, and date from the receipt.
- 🏷️ **Category Classification:** Products are categorized by keywords (e.g., Dairy, Bakery, Beverage, etc.).
- 📊 **Spending Distribution by Category:** Visualize your spending with a pie chart.
- 🏆 **Top Spending Category & Most Expensive Product:** Quick summary cards for instant insights.
- 📝 **Edit Receipts:** Edit products, prices, and categories; add or remove items as needed.
- 💾 **Local Data Storage:** Receipts are stored persistently in your browser (Hive).
- 🌐 **Fully Web-Based:** No installation required, runs directly in your browser.

---

## Screenshots

> _Screenshots will be added soon._

---

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/melihalkbk/receipt_ocr_web.git
   cd receipt_ocr_web
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run on web:**
   ```sh
   flutter run -d chrome
   ```

---

## Tech Stack

- [Flutter Web](https://flutter.dev/web)
- [Tesseract.js](https://github.com/naptha/tesseract.js) (OCR for web)
- [Hive](https://pub.dev/packages/hive) (local storage)
- [fl_chart](https://pub.dev/packages/fl_chart) (charts)
- [file_picker](https://pub.dev/packages/file_picker) (image selection)

---

## Contribution & License

- Contributions and pull requests are welcome!
- Licensed under the [MIT License](LICENSE)

---

## Developer

- [Melih Alakabak](https://github.com/melihalkbk)

---

> **Note:**  
> This project is fully client-side. Uploaded receipts and data are never sent to any server.
