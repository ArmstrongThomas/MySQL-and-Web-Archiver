# MySQL and Web Archiver

A utility batch script for archiving MySQL databases and web content, designed to run on Windows environments. This tool streamlines the process of backing up your MySQL databases and web files, compressing them using 7-Zip for efficient storage.

## Features

- **MySQL Database Archiving:** Automates the process of dumping and archiving MySQL databases.
- **Web Content Backup:** Archives website files and directories.
- **7-Zip Compression:** Uses 7-Zip for high-ratio compression (smaller archives).
- **Windows Support:** Designed for Windows, with reliance on environment PATH variables.

## Requirements

- **Windows OS**
- [MySQL](https://dev.mysql.com/downloads/mysql/) (the `mysqldump` utility must be available in your system `PATH`)
- [7-Zip](https://www.7-zip.org/) (the `7z.exe` utility must be available in your system `PATH`)

> **Note:** Both `mysqldump` and `7z` must be accessible from the command line. You can check by running `mysqldump --version` and `7z` in your terminal.

## Installation

1. **Clone the Repository**

   ```sh
   git clone https://github.com/ArmstrongThomas/MySQL-and-Web-Archiver.git
   cd MySQL-and-Web-Archiver
   ```

2. **Ensure Dependencies Are in PATH**

   - Add MySQL's `bin` directory (e.g., `C:\Program Files\MySQL\MySQL Server X.Y\bin`) to your Windows `PATH`.
   - Add 7-Zip's installation directory (e.g., `C:\Program Files\7-Zip`) to your Windows `PATH`.

3. **Configure Your Environment**

   - Edit the batch script to specify:
     - Database credentials
     - Web directories to back up
     - Output/archive destination

   > **Recommendation:**  
   > For maximum safety, set your archive/output directory to a folder that is automatically backed up or synced to a cloud service, such as Google Drive, Dropbox, or OneDrive. This ensures your backups are stored offsite and are protected against local hardware failures.

## Usage

1. **Run the Archiver Script**

   - Execute the batch file from the command line:
     ```sh
     backup.bat
     ```

   - Archives will be created in the specified output directory, typically with timestamps for versioning.

2. **Automate with Task Scheduler**

   - After configuring the script, you can schedule it to run automatically (e.g., daily) using Windows Task Scheduler:
     - Open Task Scheduler
     - Create a new task
     - Set the trigger (e.g., daily at a specific time)
     - Set the action to run your `backup.bat` script

## Troubleshooting

- **Command Not Found:**  
  If you get errors like `'mysqldump' is not recognized as an internal or external command`, ensure both MySQL and 7-Zip are in your Windows `PATH`.

## License

This project is licensed under the MIT License.

## Disclaimer

This script is provided **as is**, without warranty of any kind. The author assumes no responsibility for any damage, data loss, or failure of functionality that may result from its use. Use at your own risk.

## Author

[ArmstrongThomas](https://github.com/ArmstrongThomas)

---

Feel free to submit issues or pull requests for improvements!
