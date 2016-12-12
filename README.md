

A simple BASH script to keep an eye on laptop's battery.

Run with parameters: 

    loop [x] 

to make this script loop every [x] seconds. 
Only in loop mode one will see ETAs for charge/discharge.


Examples:

    ~ $ ./battery_monitor.bash loop 5
    BAT0 (Charging - 69.2631% remaining time 00:39:37), health 84.0%: 8.49V 2.993A 25.4106W


    ~ $ ./battery_monitor.bash 
    BAT0 (Charging - 71.5579% ), health 84.0%: 8.537V 3.095A 26.422W


    ~ $ ./battery_monitor.bash loop 5
    BAT0 (Discharging - 73.6587% remaining time 03:09:55), health 84.0%: 8.191V 1.138A 9.32136W

