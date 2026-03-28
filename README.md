# QuickPass - Flutter & Node.js QR Visitor Management System

QuickPass is a full-stack visitor management system designed to streamline the entry and exit process of visitors through automated QR code generation and scanning.

## 🚀 Tech Stack
- **Frontend**: Flutter
- **Backend**: Node.js, Express.js
- **Database**: MongoDB
- **Real-time Communication**: Socket.io
- **Authentication**: JWT (JSON Web Tokens)

## ✨ Features
- Secure user authentication and management.
- Dynamic QR code generation for streamlined visitor entry.
- Real-time status updates via Socket.io.
- Custom mobile scanner to read, verify, and track QR code access.

## 📂 Project Structure
- `app/`: The Flutter mobile application responsible for UI, tracking, and scanning.
- `backend/`: The Node.js REST API providing database operations and real-time connectivity.

## 🛠 Installation & Setup

### Prerequisites
Make sure you have the following installed on your local machine:
- [Node.js](https://nodejs.org/)
- [MongoDB](https://www.mongodb.com/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)

### Backend
1. Open your terminal and navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Install the required Node dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file in the root of the `backend` directory and provide necessary environment variables (e.g., `PORT`, `MONGO_URI`, `JWT_SECRET`).
4. Start the server:
   ```bash
   npm start
   ```

### Frontend (Flutter App)
1. Open a new terminal and navigate to the `app` directory:
   ```bash
   cd app
   ```
2. Fetch the Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the application on your desired device or emulator:
   ```bash
   flutter run
   ```

## 📄 License
Distributed under the MIT License. See the `LICENSE` file for more information.
