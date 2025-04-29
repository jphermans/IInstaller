Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Is-WindowsServer {
    $os = Get-CimInstance Win32_OperatingSystem
    return ($os.Caption -like "*Windows Server*")
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "IIS Feature Installer"
$form.Size = New-Object System.Drawing.Size(600, 650)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Install or Remove IIS Features"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($titleLabel)

# Instruction label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "This tool only works on Windows Server 2019/2022."
$infoLabel.AutoSize = $true
$infoLabel.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($infoLabel)

# CheckedListBox with IIS features
$featuresList = New-Object System.Windows.Forms.CheckedListBox
$featuresList.Size = New-Object System.Drawing.Size(550, 200)
$featuresList.Location = New-Object System.Drawing.Point(20, 80)
$features = @(
    "Web-Server",
    "Web-Common-Http",
    "Web-Health",
    "Web-Performance",
    "Web-Security",
    "Web-Windows-Auth",
    "Web-App-Dev",
    "Web-Net-Ext45",
    "Web-Asp-Net45",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-WebSockets",
    "Web-Mgmt-Tools"
)
$featuresList.Items.AddRange($features)
for ($i = 0; $i -lt $features.Count; $i++) { $featuresList.SetItemChecked($i, $true) }
$form.Controls.Add($featuresList)

# Log output
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.BackColor = "White"
$logBox.Size = New-Object System.Drawing.Size(550, 200)
$logBox.Location = New-Object System.Drawing.Point(20, 290)
$form.Controls.Add($logBox)

# Buttons
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install Selected Features"
$installButton.Size = New-Object System.Drawing.Size(180, 35)
$installButton.Location = New-Object System.Drawing.Point(20, 500)
$form.Controls.Add($installButton)

$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Text = "Remove Selected Features"
$uninstallButton.Size = New-Object System.Drawing.Size(180, 35)
$uninstallButton.Location = New-Object System.Drawing.Point(220, 500)
$form.Controls.Add($uninstallButton)

$openLogButton = New-Object System.Windows.Forms.Button
$openLogButton.Text = "Open Log File"
$openLogButton.Size = New-Object System.Drawing.Size(150, 35)
$openLogButton.Location = New-Object System.Drawing.Point(420, 500)
$openLogButton.Enabled = $false
$form.Controls.Add($openLogButton)

# Footer
$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Text = "Developed by JPHsystems"
$footerLabel.AutoSize = $true
$footerLabel.ForeColor = [System.Drawing.Color]::Gray
$footerLabel.Location = New-Object System.Drawing.Point(400, 585)
$form.Controls.Add($footerLabel)

# Reboot function
function Prompt-Reboot {
    $result = [System.Windows.Forms.MessageBox]::Show(
        "A reboot is required. Reboot now?",
        "Reboot Required",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($result -eq 'Yes') {
        Restart-Computer -Force
    } else {
        shutdown /r /t 60 /c "Scheduled reboot to complete IIS installation or removal"
    }
}

# Shared logic for install/uninstall
function Handle-Features {
    param (
        [string]$Mode # "Install" or "Remove"
    )

    $logBox.Clear()

    if (-not (Is-WindowsServer)) {
        [System.Windows.Forms.MessageBox]::Show(
            "This tool only works on Windows Server 2019 or 2022.",
            "Unsupported OS",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        $logBox.AppendText("Unsupported OS. Operation cancelled.`r`n")
        return
    }

    $action = if ($Mode -eq "Install") { "Installing" } else { "Removing" }
    $logBox.AppendText("${action} selected IIS features...`r`n")
    $logPath = "C:\IIS-${Mode}-Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $rebootNeeded = $false

    foreach ($i in 0..($featuresList.CheckedItems.Count - 1)) {
        $feature = $featuresList.CheckedItems[$i]
        $logBox.AppendText("${action}: $feature...`r`n")
        Add-Content -Path $logPath -Value "${action}: $feature"
        try {
            if ($Mode -eq "Install") {
                $result = Install-WindowsFeature -Name $feature -IncludeManagementTools -ErrorAction Stop
            } else {
                $result = Remove-WindowsFeature -Name $feature -ErrorAction Stop
            }

            if ($result.Success) {
                $logBox.AppendText("Success: $feature`r`n")
                Add-Content -Path $logPath -Value "Success: $feature"
                if ($result.RestartNeeded -eq "Yes") {
                    $rebootNeeded = $true
                }
            } else {
                $logBox.AppendText("Failed: $feature`r`n")
                Add-Content -Path $logPath -Value "Failed: $feature"
            }
        } catch {
            $logBox.AppendText("Error: $_`r`n")
            Add-Content -Path $logPath -Value "ERROR: $_"
        }
    }

    $logBox.AppendText("Operation complete.`r`nLog file: $logPath`r`n")
    Add-Content -Path $logPath -Value "Operation complete.`r`n"

    $openLogButton.Enabled = $true

    if ($rebootNeeded) {
        Prompt-Reboot
    }
}

# Hook up buttons
$installButton.Add_Click({ Handle-Features -Mode "Install" })
$uninstallButton.Add_Click({ Handle-Features -Mode "Remove" })
$openLogButton.Add_Click({ Start-Process notepad.exe $logPath })

# Show the GUI
[void]$form.ShowDialog()
