# 🌐 IIS Feature Installer GUI

A professional GUI tool to **install or remove IIS features** on Windows Server 2019/2022, built in PowerShell with support for `.exe` conversion via `ps2exe`.

---

## 🖥️ Features

✅ Install preselected IIS features  
✅ Remove selected IIS features  
✅ Visual log window and saved log file  
✅ Windows Server version check  
✅ Reboot prompt if required  
✅ Branded footer: `Developed by JPHsystems`  
✅ Compatible with `.exe` conversion  

---

## 🛠️ Requirements

- Windows Server **2019** or **2022**
- Windows PowerShell 5.1 (not PowerShell Core / 7)
- Administrator rights to install/remove features

---

## 🚀 How to Use

### 1. **Run the Installer**

> 📁 If using the `.ps1` script:
```powershell
Right-click → Run with PowerShell (as Administrator)
```

> 🟦 If using the `.exe` version:
```text
Double-click IISInstaller.exe (Run as Administrator)
```

---

### 2. **Select and Execute**

- ✅ Features are prechecked by default.
- Click **Install Selected Features** or **Remove Selected Features**.
- View progress and logs in real-time.
- A log file will be saved automatically in `C:\`.

---

### 3. **Reboot**

If required, you will be prompted:
- ✅ Yes → Reboots immediately
- ❌ No → Reboots in 60 seconds

---

## 📁 Example Log File

```
C:\IIS-Install-Log_20250429_140032.log
```

---

## 🧪 Troubleshooting

| Issue | Solution |
|------|----------|
| `Install-WindowsFeature` not recognized | You're likely on **PowerShell 7+** or **Windows 10**. Switch to **Windows PowerShell 5.1** and run on a **Server OS** |
| GUI shows OS warning | This tool only supports **Windows Server 2019/2022** |
| Reboot prompt doesn't appear | Not all features require reboot — it only shows when needed |

---

## 📦 Packaging as `.exe` (Optional)

> Make sure [ps2exe](https://github.com/MScholtes/PS2EXE) is installed:
```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

> Convert the script:
```powershell
Invoke-PS2EXE -InputFile .\Install-IISFeatures.ps1 -OutputFile .\IISInstaller.exe -NoConsole -Title "IIS Installer"
```

---

## 🏷️ Branding

**Developed by**: `JPHsystems`  
**License**: Internal use or as per your IT policies

---

## 📬 Questions or Support

Feel free to reach out to `JPHsystems` for improvements, icons, MSI bundling, or feature requests.