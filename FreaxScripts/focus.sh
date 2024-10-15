#!/bin/bash

# Get the directory where the script is located
TIMER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Files to store the study time and session info in the same directory as the script
LOG_FILE="$TIMER_DIR/study_time.log"
START_TIME_FILE="$TIMER_DIR/study_start_time.txt"
SESSION_FILE="$TIMER_DIR/study_session.txt"
PAUSE_FILE="$TIMER_DIR/study_pause_time.txt"
DAILY_TARGET=28800  # 8 hours in seconds

# Create the required files if they don't exist
touch "$LOG_FILE" "$START_TIME_FILE" "$SESSION_FILE" "$PAUSE_FILE"

# Function to dynamically list matching subjects
get_matching_subjects() {
  local input="$1"
  grep -oP " : \K.*(?= :)" "$LOG_FILE" | sort | uniq | grep -i "^$input" | head -6
}

# Function to start the timer
start_study() {
  if [ -s "$START_TIME_FILE" ]; then
    echo "Study session already started!"
  else
    while true; do
      echo "Enter the subject or project you are studying (type to auto-complete):"
      read -e SUBJECT

      # Get dynamic matching subjects
      IFS=$'\n' read -rd '' -a MATCHING_SUBJECTS <<< "$(get_matching_subjects "$SUBJECT")"

      if [ "${#MATCHING_SUBJECTS[@]}" -gt 0 ]; then
        echo "Did you mean one of these?"
        select choice in "${MATCHING_SUBJECTS[@]}" "Enter new subject"; do
          if [[ $REPLY -ge 1 && $REPLY -le ${#MATCHING_SUBJECTS[@]} ]]; then
            SUBJECT="${MATCHING_SUBJECTS[$((REPLY-1))]}"
            break
          elif [ "$REPLY" -eq $(( ${#MATCHING_SUBJECTS[@]} + 1 )) ]; then
            echo "Enter new subject:"
            read SUBJECT
            break
          else
            echo "Invalid option. Try again."
          fi
        done
      else
        echo "No matching subjects found. Proceeding with new subject."
      fi

      # Start the session
      date +%s > "$START_TIME_FILE"
      echo "$SUBJECT" > "$SESSION_FILE"
      echo "Study session for '$SUBJECT' started at $(date)"
      notify-send "Study Timer" "Study session for '$SUBJECT' started!"
      break
    done
  fi
}

# Function to pause the timer
pause_study() {
  if [ -s "$PAUSE_FILE" ]; then
    echo "Session is already paused!"
  elif [ -s "$START_TIME_FILE" ]; then
    PAUSE_TIME=$(date +%s)
    echo "$PAUSE_TIME" > "$PAUSE_FILE"
    echo "Study session paused at $(date)!"
    notify-send "Study Timer" "Study session paused!"
  else
    echo "No active study session to pause!"
  fi
}

# Function to resume the timer
resume_study() {
  if [ ! -s "$PAUSE_FILE" ]; then
    echo "No paused session to resume!"
  else
    PAUSE_TIME=$(cat "$PAUSE_FILE")
    RESUME_TIME=$(date +%s)

    # Calculate the total pause duration and add it to the session
    PAUSE_DURATION=$((RESUME_TIME - PAUSE_TIME))
    START_TIME=$(cat "$START_TIME_FILE")
    NEW_START_TIME=$((START_TIME + PAUSE_DURATION))  # Adjust start time to exclude pause
    echo "$NEW_START_TIME" > "$START_TIME_FILE"

    # Remove the pause file as we are resuming the session
    rm "$PAUSE_FILE"

    echo "Study session resumed at $(date)!"
    notify-send "Study Timer" "Study session resumed!"
  fi
}

# Function to stop the timer and calculate study time
stop_study() {
  if [ ! -s "$START_TIME_FILE" ]; then
    echo "No study session in progress!"
  else
    START_TIME=$(cat "$START_TIME_FILE")
    END_TIME=$(date +%s)

    # If the session was paused and not resumed, calculate the correct end time
    if [ -s "$PAUSE_FILE" ]; then
      PAUSE_TIME=$(cat "$PAUSE_FILE")
      PAUSE_DURATION=$((END_TIME - PAUSE_TIME))
      END_TIME=$((END_TIME - PAUSE_DURATION))  # Adjust end time to exclude the pause time
      rm "$PAUSE_FILE"  # Clear the pause file
    fi

    STUDY_TIME=$((END_TIME - START_TIME))
    SUBJECT=$(cat "$SESSION_FILE")
    TOTAL_STUDY_TIME=$(get_daily_total_study_time)

    # Append today's date, subject, and study time to the log file
    echo "$(date '+%Y-%m-%d') : $SUBJECT : $STUDY_TIME seconds" >> "$LOG_FILE"

    # Remove session and start time files
    rm "$START_TIME_FILE" "$SESSION_FILE"

    echo "Study session for '$SUBJECT' stopped! Duration: $((STUDY_TIME / 60)) minutes"
    notify-send "Study Timer" "Study session stopped! Total: $((TOTAL_STUDY_TIME / 60)) minutes today!"
  fi
}

# Function to reset the log file and daily graph at midnight
reset_study_time() {
  echo "Resetting study time log for a new day..."
  echo "$(date '+%Y-%m-%d') : 0 seconds" >> "$LOG_FILE"
  notify-send "Study Timer" "New day started, reset study log."
  # Clear the daily graph data file
  : > "$TIMER_DIR/daily_data.txt"  # Reset the daily data file to be empty
  rm -f "$TIMER_DIR/daily_summary.png"  # Remove the existing daily summary graph if exists
  notify-send "Study Timer" "Daily graph reset."
}

# Function to get total study time for the current day
get_daily_total_study_time() {
  TODAY=$(date '+%Y-%m-%d')
  TOTAL_TIME=$(awk -F" : " -v date="$TODAY" '$1 == date {sum += $3} END {print sum}' "$LOG_FILE")
  echo "$TOTAL_TIME"
}

# Function to generate daily summary report
daily_summary() {
  TOTAL_TIME=$(get_daily_total_study_time)
  HOURS=$((TOTAL_TIME / 3600))
  MINUTES=$(( (TOTAL_TIME % 3600) / 60 ))
  echo "Total study time today: $HOURS hours and $MINUTES minutes."
  notify-send "Study Timer" "Daily Summary: $HOURS hours and $MINUTES minutes today."

  if [ "$TOTAL_TIME" -ge "$DAILY_TARGET" ]; then
    echo "Congratulations! You've reached your daily target of 8 hours!"
  else
    REMAINING=$((DAILY_TARGET - TOTAL_TIME))
    echo "You have $((REMAINING / 3600)) hours and $(((REMAINING % 3600) / 60)) minutes remaining to meet your daily target."
  fi

  generate_graph "minutes"  # Default to minutes for initial graph display
  dynamic_graph_viewing
}

# Function to generate weekly summary report
weekly_summary() {
  START_DATE=$(date --date="7 days ago" +%Y-%m-%d)
  TOTAL_TIME=$(awk -F" : " -v start="$START_DATE" '$1 >= start {sum += $3} END {print sum}' "$LOG_FILE")
  HOURS=$((TOTAL_TIME / 3600))
  MINUTES=$(( (TOTAL_TIME % 3600) / 60 ))

  echo "Total study time for the last 7 days: $HOURS hours and $MINUTES minutes."
  notify-send "Study Timer" "Weekly Summary: $HOURS hours and $MINUTES minutes."

  generate_graph "minutes"  # Default to minutes for initial graph display
  dynamic_graph_viewing
}

# Function to generate a graphical report using gnuplot (switch between minutes/hours)
generate_graph() {
  local TIME_UNIT=$1  # Time unit: "minutes" or "hours"
  local CONVERT_FACTOR=60  # Default to minutes
  local YLABEL="Minutes"

  if [[ "$TIME_UNIT" == "hours" ]]; then
    CONVERT_FACTOR=3600
    YLABEL="Hours"
  fi

  # Regenerate the graph dynamically when the user presses a key
  TODAY=$(date '+%Y-%m-%d')
  awk -F" : " -v date="$TODAY" -v factor="$CONVERT_FACTOR" '$1 == date {print $2, $3/factor}' "$LOG_FILE" | \
    awk '{a[$1]+=$2} END{for(i in a) print i, a[i]}' > "$TIMER_DIR/daily_data.txt"

  if [ ! -s "$TIMER_DIR/daily_data.txt" ]; then
    echo "No data for today, cannot generate graph."
    return
  fi

  gnuplot -persist <<EOF
    set terminal png size 800,600
    set output "$TIMER_DIR/daily_summary.png"
    set title "Daily Study Time per Subject (in $YLABEL)"
    set xlabel "Subjects"
    set ylabel "$YLABEL"
    set style data histograms
    set style fill solid border -1
    set boxwidth 0.7
    set grid ytics
    set xtic rotate by -45
    set key off
    plot "$TIMER_DIR/daily_data.txt" using 2:xtic(1) title "$YLABEL per Subject"
EOF

  # Open the generated graph automatically
  xdg-open "$TIMER_DIR/daily_summary.png" &

  echo "Graphical report for today saved as daily_summary.png"
  notify-send "Study Timer" "Graphical report updated in $YLABEL."
}

# Function to dynamically switch between minutes and hours while generating the graph
dynamic_graph_viewing() {
  echo "Press 'm' to view graph in minutes or 'h' to view graph in hours."
  echo "Press 'q' to quit."
  while true; do
    read -n1 -s key  # Read one key without requiring Enter

    case $key in
      m)
        echo -e "\nSwitching to Minutes..."
        generate_graph "minutes"
        ;;
      h)
        echo -e "\nSwitching to Hours..."
        generate_graph "hours"
        ;;
      q)
        echo -e "\nExiting graph viewing..."
        break
        ;;
      *)
        echo -e "\nInvalid input. Press 'm' for minutes, 'h' for hours, or 'q' to quit."
        ;;
    esac
  done
}

# Function to reset the weekly log
reset_weekly_summary() {
  echo "Resetting weekly study time log..."
  echo "Date : Subject : Time (seconds)" > "$TIMER_DIR/weekly_data.txt"  # Clears the file but keeps the headers
  notify-send "Study Timer" "Weekly summary and graph reset."

  # Regenerate an empty graph
  gnuplot -persist <<EOF
    set terminal png size 800,600
    set output "$TIMER_DIR/weekly_summary.png"
    set title "Weekly Study Time per Subject"
    set xlabel "Subjects"
    set ylabel "Minutes"
    set style data histograms
    set style fill solid border -1
    set boxwidth 0.7
    set grid ytics
    set xtic rotate by -45
    set key off
    plot NaN title "No data"
EOF
}

# Function to reset the study_time.log file
reset_log() {
  read -p "Do you want to delete the study log? (yes/no): " choice
  if [[ "$choice" == "yes" ]]; then
    echo "Resetting study time log..."
    > "$LOG_FILE"  # Clear the contents of the log file
    echo "Study time log has been reset."
  else
    echo "No resetting"
  fi
}

# Main script execution
case "$1" in
  "start")
    start_study
    ;;
  "stop")
    stop_study
    ;;
  "pause")
    pause_study
    ;;
  "resume")
    resume_study
    ;;
  "reset")
    reset_study_time
    ;;
  "daily_summary")
    daily_summary
    ;;
  "weekly_summary")
    weekly_summary
    ;;
  "reset_weekly")
    reset_weekly_summary
    ;;
  "reset_log")
    reset_log
    ;;
  *)
    echo "Usage: $0 {start|stop|pause|resume|reset|daily_summary|weekly_summary|reset_weekly|reset_log}"
    ;;
esac
