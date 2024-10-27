<div align="center">
  <h1>Productivity Powerhouse for Linux! </h1>
</div>

<p>Designed with <strong>professionals</strong> in mind, it is a complete go-to solution for tracking and managing work sessions effectively in the <strong>Linux environment</strong>! 🐧✨</p>

---

## 🌟 Why Choose **Freax**?

In a world where productivity tools are abundant on Windows but scarce on Linux, **Freax** fills the gap!
<br>
It’s time to elevate your focus sessions and streamline your productivity like never before! 🔥

---

## Table Of Contents:

- [Installation](#installation)
- [Features](#features)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Installation:

Ready to unleash the power of **Freax**? Follow these simple steps to get started! 🎉

### Step 1: Clone the Repository

First, you'll want to bring **Freax** to your local machine! Open your terminal and run the following command:<br>

```bash
git clone https://github.com/VahantSharma/Freax.git
cd Freax
ls
```

**NOTE:** You should see a folder named FreaxScripts and Readme.md file<br>

### Step 2: Navigate to FreaxScripts
```bash
cd FreaxScripts
```

### Step 3: Giving Permissions to the Scripts

```bash
chmod +x focus.sh get_folder.sh
```

### Step 3: Setting up the Aliases(shortcuts)

To make using Freax even easier,set up some aliases so you can control your study sessions with just a few keystrokes

- Run the get_folder.sh file which in turn setup the aliases in .bashrc or .zshrc file
  
  - For those using Bash
    ```bash
    bash ./get_folder.sh
    ```
  - For those using ZSH
    ```bash
    zsh ./get_folder.sh
    ```  
- Source these changes to use them immediately
    - For those using Bash
    ```bash 
    source .bashrc
    ```
   - For those using ZSH
    ```bash
    source .zshrc
    ```

### Step 4: Crontab Setup
- To automate the daily and weekly resets, make sure cron is installed and running on your system.
- This will install, open cron and setup daily and weekly reset
```bash
sudo apt-get install cron
systemctl status cron
vim crontab -e
# Daily reset at 12 AM
0 0 * * * $FOCUS_REPO_DIR/focus.sh reset

# Weekly reset on Sunday at 12 AM
0 0 * * 0 $FOCUS_REPO_DIR/focus.sh reset_weekly
```

### Step 5: Graph Plotting
To plot graphs of your study data, you need to install gnuplot:

```bash
sudo apt install gnuplot
gnuplot -v
exit
```
**NOTE:** GNUPLOT version should be visible after this

#### Mission accomplished:

Now you're all set to start using Freax and maximize your productivity! 🎉✨\*\*

---

## Usage

Now that you have **Freax** installed, let's get started with tracking your productivity! Here are some simple commands to manage your study sessions:

### Command Descriptions

| Command           | Description                                                                                                                                       |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| **focuson**       | - Starts the timer <br> - Prompts for a work subject <br> - Gives autosuggestions if studied in the last 7 days <br> - Provides notification. |
| **focusoff**      | - Stops the timer <br> - Shows time spent on the topic <br> - Prepares the daily summary.|
| **focuspause**    | Pauses the current study session.                                                                                                                  |
| **focusresume**   | Resumes the paused study session.                                                                                                                  |
| **daily_summary** | - Displays total time spent <br> - Shows hours remaining in your daily target <br> - Provides a productivity graph (viewable in minutes or hours). |
| **focusreset**    | Clears the daily log by removing all entries for the day.                                                                                          |
| **focusweeklyreset** | Clears all data from the weekly log.                                                                                                            |

## Features:

### **Basic Features**

- **Start Study Session**: Begin a new study session to track your time.
- **Stop Study Session**: Stop your current study session and log the time spent.
- **Pause/Resume**: Temporarily pause your session and resume it later without losing progress.
- **Daily Summary**: Retrieve a detailed summary of study time for the day.

### **Intermediate Features**

- **Weekly Summary**: Get an overview of your productivity over the past week, helping to analyze trends.
- **Session Reset**: Easily reset your current focus session to start fresh.
- **Daily Hour Targets**: Set specific hour targets for your study sessions to maintain focus and motivation.

### **Advanced Features**

- **Graphical Analysis**: Visualize your productivity with dynamic graphs that display time spent in hours or minutes.
- **Subject Autocompletion**: Save time while logging sessions with intelligent suggestions for subjects.
- **Real-Time Notifications**: Receive notifications to celebrate your achievements and stay motivated.
- **Industry-Grade Design**: Built with professional standards, ensuring reliability and ease of use.

---

## Contributing

We welcome contributions to **Freax** from everyone! Here are some areas where you can help enhance the project:

### Areas for Contribution Required:

| **Area**                   | **Contribution Details**                                                                                                                                                                                                                                                                                               |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bug Fixes**              | - Identify and resolve bugs or issues in the existing codebase. <br>- Improve stability and performance of the application.                                                                                                                                                                                            |
| **Feature Development**    | - **Session Comments**: <br> &nbsp; - **Add Notes**: Allow users to add comments to each study session for context (e.g., topics covered, challenges faced). <br><br> - **Voice Control**: <br> &nbsp; - **Voice Commands**: Implement voice command functionality for starting, stopping, and logging study sessions. |
| **Documentation**          | - Enhance clarity and completeness of the README and other documentation files. <br>- Add examples and tutorials for user guidance.                                                                                                                                                                                    |
| **Testing**                | - Write unit and integration tests to ensure code quality. <br>- Assist in creating a testing framework for improved coverage.                                                                                                                                                                                         |
| **Graphical Improvements** | - **Improved Graphing**: Use various graph types (pie charts, line graphs) for comprehensive visual summaries. <br> &nbsp; - **Graph Interactivity**: Enable users to click on graph elements for detailed study time info per subject.                                                                                |
| **UI/UX Enhancements**     | - Suggest or implement improvements to the user interface. <br>- Conduct user experience research to make Freax more intuitive.                                                                                                                                                                                        |

Contributing to **Freax** is simple and straightforward. Here’s how you can get involved:

### **How to Contribute**

1. **Fork the Repository**

   - Click the **"Fork"** button on the top right of the repository page to create your own copy of **Freax**.

2. **Clone Your Fork**

   - Open your terminal and run:

   ```bash
   git clone https://github.com/yourusername/Freax.git
   cd Freax

   ```

3. **Make Your Changes**

- Add your features, fix bugs, or improve documentation. Make sure to test your
  changes!

4. **Commit Your Changes**

- Save your changes with a commit message:

```bash
Save your changes with a commit message:
```

5. **Push Your Changes**

- Push your changes to your fork:

```bash
git push origin main
```

6. **Create a Pull Request**

- Go back to the original Freax repository, click on the "Pull Requests" tab, and then click "New Pull Request".
- Select your branch and submit the pull request.

#### You're Awesome!

Thank you for considering contributing to Freax! If you have any questions or need help, feel free to reach out. Let’s make Freax even better together! 🎉

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### MIT License

---

## 💬 Support

Have questions or feedback? Open an issue in the repository! Your input is essential for continuous improvement! 🚀

---
    
