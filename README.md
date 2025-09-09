# 🚗 Car Dealership Web Application

A modern, full-stack car dealership web application with a beautiful turquoise theme, built with Django, Node.js, and React.

## ✨ **Features**
- 🏠 **Homepage** with dealership overview
- 👥 **About Us** page with team information  
- 📞 **Contact Us** page with support details
- 🔐 **User Authentication** (Login/Register)
- 🏪 **View Dealerships** with filtering
- ⭐ **Review System** with sentiment analysis
- 📱 **Responsive Design** with modern UI/UX
- 🎨 **Consistent Branding** with turquoise color scheme

## 🚀 **Quick Start**

### Option 1: Use Startup Script (Recommended)
```bash
# Clone the repository
git clone https://github.com/emiflair/fullstack_developer_capstone.git
cd fullstack_developer_capstone

# Run startup script
./start.sh          # On macOS/Linux
# OR
start.bat          # On Windows
```

### Option 2: Manual Setup
See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

## 🌐 **Access Points**
- **Main Application**: http://localhost:8000
- **Database API**: http://localhost:3030

## 🛠 **Tech Stack**
- **Backend**: Django 4.2.24 (Python)
- **Database API**: Node.js + Express  
- **Frontend**: React 18
- **Styling**: Custom CSS with turquoise theme
- **Data Storage**: JSON files

## 📱 **Available Pages**
1. **Homepage** - Welcome and navigation
2. **About Us** - Team member profiles
3. **Contact Us** - Support information
4. **Login/Register** - User authentication
5. **Dealerships** - Browse all dealerships
6. **Dealer Details** - Individual dealership with reviews
7. **Write Review** - Submit new reviews

## 🎯 **Key Improvements Made**
- ✅ **Modern UI Design** - Professional, clean interface
- ✅ **Consistent Color Scheme** - Turquoise/cyan branding
- ✅ **Organized Forms** - Well-structured review submission
- ✅ **Responsive Layout** - Works on all screen sizes
- ✅ **Interactive Elements** - Hover effects and animations
- ✅ **Form Validation** - Client-side error handling
- ✅ **One-Click Deployment** - Automated startup scripts

## 📂 **Project Structure**
```
fullstack_developer_capstone/
├── start.sh / start.bat     # Startup scripts
├── DEPLOYMENT_GUIDE.md      # Detailed setup guide
├── server/
│   ├── djangoapp/          # Django application
│   ├── djangoproj/         # Django project settings
│   ├── database/           # Node.js API server
│   ├── frontend/           # React application
│   └── static/             # Static files
└── README.md
```

## 🔒 **Locked Configuration**
This application is configured to maintain consistency across deployments:
- All dependencies locked in requirements.txt and package.json
- React build process automated
- Color scheme standardized (#23e0e0)
- Deployment scripts ensure identical setup

## 💡 **For Developers**
- React components use inline styles for consistency
- Django serves pre-built React files
- Database API runs on separate port (3030)
- All styling follows the turquoise theme

## 🤝 **Contributing**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with startup scripts
5. Submit a pull request

## 📞 **Support**
Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for troubleshooting and detailed setup instructions.

---
**🚀 Ready to deploy? Just run `./start.sh` and visit http://localhost:8000**