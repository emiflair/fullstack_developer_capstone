# 🚗 Car Dealership Web Application - Deployment Guide

## 📋 **Overview**
This is a full-stack car dealership web application with Django backend, Node.js database API, and React frontend.

## 🛠 **Tech Stack**
- **Backend**: Django 4.2.24 (Python)
- **Database API**: Node.js + Express (Port 3030)
- **Frontend**: React 18 (Built and served by Django)
- **Database**: JSON file-based storage
- **Styling**: Custom CSS with turquoise/cyan theme

## 🎯 **Features**
- Homepage with dealership overview
- About Us page with team information
- Contact Us page
- User authentication (Login/Register)
- View all dealerships
- Individual dealership pages with reviews
- Write and submit reviews
- Responsive design with modern UI

## 🚀 **Quick Start**

### Prerequisites
- Python 3.9+
- Node.js 14+
- npm or yarn

### 1. Clone Repository
```bash
git clone https://github.com/emiflair/fullstack_developer_capstone.git
cd fullstack_developer_capstone
```

### 2. Backend Setup (Django)
```bash
# Navigate to server directory
cd server

# Create virtual environment
python -m venv .venv

# Activate virtual environment
# On macOS/Linux:
source .venv/bin/activate
# On Windows:
.venv\Scripts\activate

# Install Python dependencies
pip install -r requirements.txt

# Run Django migrations
python manage.py migrate

# Start Django server (Port 8000)
python manage.py runserver 0.0.0.0:8000
```

### 3. Database API Setup (Node.js)
```bash
# In a new terminal, navigate to database directory
cd server/database

# Install Node.js dependencies
npm install

# Start database API server (Port 3030)
node app.js
```

### 4. Frontend Setup (React)
```bash
# Navigate to frontend directory
cd server/frontend

# Install React dependencies
npm install

# Build React application
GENERATE_SOURCEMAP=false npm run build
```

## 🌐 **Access the Application**
- **Main Application**: http://localhost:8000
- **Database API**: http://localhost:3030

## 📁 **Project Structure**
```
fullstack_developer_capstone/
├── server/
│   ├── djangoapp/          # Django app
│   ├── djangoproj/         # Django project settings
│   ├── database/           # Node.js API server
│   │   ├── app.js         # Main API server
│   │   ├── data/          # JSON data files
│   │   └── package.json
│   ├── frontend/          # React application
│   │   ├── src/
│   │   ├── build/         # Built React files
│   │   └── package.json
│   ├── static/            # Static files
│   ├── manage.py
│   └── requirements.txt
├── DEPLOYMENT_GUIDE.md
└── README.md
```

## 🎨 **UI/UX Features**
- **Consistent Color Scheme**: Turquoise/cyan (#23e0e0) theme
- **Modern Design**: Clean, professional interface
- **Responsive Layout**: Works on desktop and mobile
- **Interactive Elements**: Hover effects and smooth transitions
- **Form Validation**: Client-side validation with error messages

## 🔧 **Configuration**

### Environment Variables
The application uses default configurations but can be customized:
- Django runs on port 8000
- Database API runs on port 3030
- React build files are served by Django

### Database
Uses JSON files for data storage:
- `server/database/data/dealerships.json` - Dealership data
- `server/database/data/reviews.json` - Review data
- `server/database/data/car_records.json` - Car models data

## 🚨 **Important Notes**

### Production Deployment
1. **Build React App**: Always run `npm run build` before deployment
2. **Static Files**: Ensure Django serves React build files correctly
3. **CORS**: Database API has CORS enabled for local development
4. **Security**: Update SECRET_KEY and security settings for production

### Troubleshooting
1. **Template Errors**: Ensure React build completed successfully
2. **API Errors**: Check if database server is running on port 3030
3. **CORS Issues**: Verify API server CORS configuration
4. **Static Files**: Check Django STATICFILES_DIRS configuration

## 📱 **Pages Available**
1. **Homepage** (`/`) - Welcome page with navigation
2. **About Us** (`/about/`) - Team information
3. **Contact Us** (`/contact/`) - Contact details
4. **Login** (`/login/`) - User authentication
5. **Register** (`/register/`) - User registration
6. **Dealerships** (`/dealers/`) - List all dealerships
7. **Dealer Details** (`/dealer/{id}`) - Individual dealership with reviews
8. **Write Review** (`/postreview/{id}`) - Submit new review

## 🎯 **Key Features Implemented**
- ✅ Professional UI with consistent branding
- ✅ User authentication system
- ✅ CRUD operations for reviews
- ✅ Responsive design
- ✅ Form validation
- ✅ Error handling
- ✅ Modern React components
- ✅ RESTful API integration

## 💡 **Development Tips**
1. Use `python manage.py runserver 0.0.0.0:8000` for Django
2. Use `node app.js` for database API
3. Rebuild React after changes: `npm run build`
4. Check browser console for JavaScript errors
5. Monitor Django logs for backend issues

## 🤝 **Contributing**
1. Fork the repository
2. Create a feature branch
3. Make changes
4. Build React app
5. Test thoroughly
6. Submit pull request

## 📞 **Support**
For issues or questions, please check:
1. This deployment guide
2. Console logs (browser & terminal)
3. Django debug information
4. API response logs

---
**Version**: 1.0  
**Last Updated**: September 2025  
**Maintainer**: emiflair
