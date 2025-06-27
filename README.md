# LSC_Indoor_camera
In this repo i will share some files and scripts of my adventure in hardware hacking a LSC indoor camera from Action. 

# Story
I am in my hardwarehacking phase where i buy or get embedded devices like routers, cameras, tv setopboxes and other consumer devices where i explore and find vulnerabilities and just how its build up. I like this because you can learn a lot from those devices and the thought and engineering process behind them. And its fun to hook into the serial ports on those devices and see what is going on behind the scenes. 
I bought this camera at Action yesterday (Action is a german dutch store that sells all sorts of things for a cheap price) because i thought 'This might run embedded linux" And i was right! I opened it up and started looking for a serial port which i quickly found and i attached my usb to uart converter to to see if i can view the device logs. I also wanted to look at the security of these devices because they are cheap and are usually just Tuya gear thats rebranded and Tuya is chinese and IOT has been know for its Insecurity (Its where the 'I' in IOT stands for :) ). I connected it to the app first to see if everything was functioning and then i started my adventure. 

# The device itself
![1000179976](https://github.com/user-attachments/assets/aaf8a048-2327-4080-abb7-1935c3606eec)

![1000179977](https://github.com/user-attachments/assets/20d43b8e-94a3-405b-ae03-0f865bdbbb2e)

![1000179978](https://github.com/user-attachments/assets/bbf84f3f-00db-4c68-a106-54fb96eff541)



# Teardown and analysis
As you can see, you have to pry it open at the front. Stick a spudger or screwdriver between the edge and the black front plastic and then it should pop off. 
Once inside you can see the main components: 
![1000179980](https://github.com/user-attachments/assets/a68bf4c5-1f08-46c2-8c72-576620a57792)
![1000179981](https://github.com/user-attachments/assets/915324e0-cba0-4730-9553-00cbbb5134b7)
The main soc (the heart) of the camera is a Ingenic T23N. This chip is quite beefy. It has 1 main Xburst cpu core running at max 1.4ghz. And it also has a coprocessor which is a RiscV mcu core runing at 600mhz. And it has all the hardware and blocks that allow it to function in an IP camera platform like Some Tuya or other vendor. The Xburst runs the Linux os and the riscV some firmware or RTOS:
![1000179993](https://github.com/user-attachments/assets/e4816159-0678-4f54-a028-266b6b6fc4ee)
![image](https://github.com/user-attachments/assets/84f89b41-a1fb-4083-8087-2f9241c109d2)

Underneath the soc there is a flash chip by XMC which is a 25qh64 which is just one variant of the clasic 25 series SPI flash chips. In this case our chip is 8 megaBYTE because its 64 megaBIT / 8 = 8 Megabyte. This chip stores the firmware and has a few partitions we will take a look at further in a few moments:
![1000179990](https://github.com/user-attachments/assets/e27e9cd8-fb02-4e1c-9f5c-86e46139ebb5)

We also see a Altobeam atbm6012b which is the wireless chipset which comminucates with the main SOC over usb or SDIO but in our case its usb:
![1000179991](https://github.com/user-attachments/assets/04adf08b-9977-4947-ac6e-d859a54ab180)

# Diving deeper and some Logs
So next i hooked up a UART to the pins on the board. I did not make a photo of before i put a blob of glue on it but under it are some pads that are clearly marked RX, TX and Gnd. Soi hooked up the TX of my Usb to uart to the RX on the device and RX of the usb to uart to TX on the device and Gnd to Gnd. Thats all you need, please do NOT connect power! Then i covered it with glue to avoid easily riping off the pcb pads which happened on some earlier devices:
![1000179982](https://github.com/user-attachments/assets/c848228a-e0ce-4e1e-9b4d-f88980ef4c74)

After i did that and started a terminal session on my pc, I could view the logs. I am on Debian Linux so i use picocom but you can use putty or minicom if you desire: 
[Bootlogs](https://github.com/RX309Electronics/LSC_Indoor_camera/blob/main/bootlog.txt)
Seems the engineers/devs had time and fun to embed a nice little 'splash' into the boot output. From these logs we can see that it uses Das U-boot (or simply U-boot) as a bootloader. U-boot is common on embedded devices and runs in millions of devices and hardware combinations and its opensource meaning you can tweak it how much you want and that makes it nice and easy to strip down on storage limited devices like embedded devices. It also runs Linux 3.10.14 which is common for Ingenic chips. And the __isvp_pike_ is the codename of the chip. 'Pike' is common for Ingenic T23 chips. Below is a table of codenames for the chips. And the isvp part means 'Ingenic Smart video platform'. 

| Chip  |Codename |
| ----- | --------|
| T10   | Mango  |  
| T20   | Bull   |
| T21   | Turkey |
| T23   | Pike   |
| T30   | Monkey |
| T31   | Swan   |
| T40   | Shark  |
| T41   | Marmot |

# Launching into a rootshell and doing basic Init steps. 
When it boots up normally it starts up everything but then it presents a password protected rootshell. We can simply bypass this and prevent the app starting throwing a bunch of gargabge in the terminal by going into the U-boot bootloader and changing the kernel parameters which are the bootargs. You might have seen in the Uboot environment file that the bootcmd runs up_boot_args which simply updates the bootargs parameter. This up_bootargs parameter looks like this:
```
up_bootargs=setenv bootargs console=ttyS1,115200n8 mem=${holily_mem}M@0x0 rmem=18M@0x2e00000 init=/linuxrc rootfstype=squashfs root=/dev/mtdblock5 rw mtdparts=${mtdparts}.
```
As you can see standard kernel parameters, and this is where we can break in. By changing the 'Init' or 'rdinit' parameter from standard '/linuxrc' to '/bin/sh' we basically say to the kernel to run /bin/sh (standard busybox shell) as PID 1 process. In Unix and *Nix PID 1 is the process that inmideatly runs after the kernel has initialised and runs till the device is shut off and has to keep running the whole time (otherwise you get a kernel panic). /linuxrc basically runs the standard init scripts and starts the application while /bin/sh presents a non-passsword-protected shell to us.
Here are the commands to update the up_bootargs to bypass the normal init:
```
setenv up_bootargs'setenv bootargs console=ttyS1,115200n8 mem=${holily_mem}M@0x0 rmem=18M@0x2e00000 init=/bin/sh rootfstype=squashfs root=/dev/mtdblock5 rw mtdparts=${mtdparts}'.
saveenv
boot
```

 After it has booted it should present a shell to us. If we are in the shell, there are a few things we have to do first. Because we bypassed the normal Init process we have to manually execute some commands to mount the standard required Linux directories and to prepare the system just like the normal Init process did. First we mount the required filesystems, run the commands below in the shell i extracted from the rcS script in the filesystem:
```
mount -t tmpfs tmpfs /dev
mkdir -p /dev/pts
mkdir -p /dev/shm
mount -a
mount -av
```
## Mounting and preparing the environment for the Tuya stuff
Now it should have mounted the basic Linux directories like proc, dev and sys, now most commands should also work. But we also need to mount the other partitions so we can get acess to the juicy Tuya custom stuff. 
Simply run these commands below: 
```
echo /sbin/mdev > /proc/sys/kernel/hotplug
/sbin/mdev -s && echo "mdev is ok......"
mkdir /var/cache
mkdir /var/run
mkdir /var/log
mkdir /var/spool
mkdir -p /mnt/config
mount -t jffs2 /dev/mtdblock6 /mnt/config
mount -t squashfs /dev/mtdblock7 /usr
mount --bind /usr/modules /lib/modules
tmp_etc_dir=/tmp/etc
cp -Rf /etc/  $tmp_etc_dir
/bin/mount --bind $tmp_etc_dir/ /etc/
/bin/mount --bind /mnt/config /data/
ifconfig lo 127.0.0.1
export PATH=/tmp/bin:/tmp/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
export LD_LIBRARY_PATH=/tmp/lib:/lib:/usr/lib:/usr/local/lib
```

After that you should have access to the config files in /mnt/config and the Tuya stuff in /usr and /usr/local. I also included all commands in a file called 'basic_init' which contains all the commands to mount the basic /dev, /sys and /proc directories and mount the config and Tuya USR partition and prepare the system you can simply copy and paste [This](https://github.com/RX309Electronics/LSC_Indoor_camera/blob/main/basic_init). into the shell. This script contains eveyrhting from the inittab, rcS and start_app script thats needed to set up the environment and load drivers.

# Analysing the system
After you are into the shell you can do a lot of things because its just a basic Linux system with a few utilities and commands. 
First thing i always do i simply look at the partition table. The Linux kernel also gives this on boot but it might scroll by realy fast so in this way you can eaisly study it without bunch of text filling the terminal. Simply run 'cat /proc/mtd' and it shows the partition table and even the adresses and size of the partitions. Below i have put all info into a nice table:

| Partition | Size     | Erase size | Name |
------------|----------|----------- |------|
| mtd0:     | 00040000 |   00008000 | UBT  |
| mtd1:     | 00008000 |   00008000 | ENV  |
| mtd2:     | 00008000 |   00008000 | N/A  |
| mtd3:     | 00008000 |   00008000 | N/A  |
| mtd4:     | 001a0000 |   00008000 | K    |
| mtd5:     | 00100000 |   00008000 | RT   |
| mtd6:     | 00040000 |   00008000 | CFG  |
| mtd7:     | 004d8000 |   00008000 | USR  |
| mtd8:     | 00800000 |   00008000 | SFC  |
[Raw output + descriptions](https://github.com/RX309Electronics/LSC_Indoor_camera/blob/main/partition_table)

# Dumping the filesystem
Next i will try dumping the flash/filesystem. Instead of desoldering the flash we can do it straight from the busybox userland. You only need a sdcard (formatted as fat) and [This file](https://raw.githubusercontent.com/RX309Electronics/LSC_Indoor_camera/main/dumpfw.sh). Simply copy the file to the sdcard, make sure its executable (If its not, set the executable flag. FIrst go to the directory the file is in and then execute this command in your host's shell:
```
chmod +x dumpfw.sh
```

Than eject the sdcard and plug it into the camera. Next you have to mount it from within the userland. Execute this in the busybox shell:
```
mkdir /tmp/sdcard
mount /dev/mmcblk0p1 /tmp/sdcard
```

Then simply go into this directory and execute the script with:
```
./dumpfw.sh
```

After a few seconds its done and it should have dumped the partitions it can access (except the N/A partitions). You should see the partition name with a .bin extension and those are the raw partitions. Now you can use binwalk to extract them:
```
binwalk -e {filename}
```

# The filesystems
First of all we got the rootfilesystem which is a squashfs and its indeed the RT partition. In it we find commoon Linux/*nix folders. I dont think i have to really explain them because if you know the basis of linux then you should be familiar with these and otherwise, online is enough information about linux and directries:
> /bin /dev /etc /lib /mnt /proc /sbin /sys /tmp /usr /var. And a linuxrc file which is a symlink to busybox. 

Then we have the USR partition which not only contains standard /usr files and data but also has the fun stuff inside it:
|  /usr    | What it Contains                                         |
-----------|--------------------------------------------------------- |
|  /bin    | Nothing                                                  |
|  /lib    | Libraries like libgcc and libstdc++                      |
|  /local  | The fun stuff                                            |
|  /modules| Kernel modules                                           |
|  /share  | Files with chip name. date, solution vendor and vbersion |


/usr/local/ is what is interesting to us 
| /usr/local/ | What it contains                                                               |
|-------------|--------------------------------------------------------------------------------|
| /bin        | Contains all the custom programs                                               |
| /etc_addon  | Contains webrtc_profile.txt which seems to be for Web Real Time Comminucation. |
| /isp        | Binary blobs for the different sensor modules/chips                            |
| /lib        | Contains 1 library called libaudioprocess.so which i think is for Audio        |
| /resource   | Contains all the mp3 audio/sound files and a single font.                      |
| /sbin       | Contains all scripts for starting, stopping the app, system upgrade and load modules |


In the bin folder are 2 main binaries. A dokodemo binary and a doraemon binary, both custom made by WhaleVT (Shenzen Whale Video Technology corporation). Next to those 2 binaries are also a bunch of applications which are just specific symlinks to the doraemon binary all with different arguments and parameters. So they are not real applications but they call the doraemon binary in a specific way that executes that specific function. Seems this big boy binary (7.4 megabyte) is what does the heavy lifting. It comminucates with the Tuya servers, processes video, handles the wifi via the wireless chip, controls the whole system and Its the soul of the camera, it makes this product an IP camera. 
All the custom applications (which are symlinked to the big doraemon binary) are listed below:
> assistant_voice, audio_frequency_spectrum, aux_ir, baby_cry_detection, ipc_boot_env, ipc_factory_activate, ipc_info, ipc_mini_service, ipc_onvif_nvt, ipc_performance_test, ipc_pin_assignment, ipc_service, ipc_upgrade, ipc_upgrade_amend_boot, ipc_upgrade_discovery, ipc_watchdog, oops, selfcheck_audio, standardize_motor_direction, temperature, test_ipc_audio_output, test_ipc_babycry_detect, test_ipc_qrcode_scanning, test_ipc_rtsp_server, wifi_access_point_survey, wifi_station.


And CFG contains the Tuya configuration files which i found less interesting so hence i did not write about it.


# Some fun stuff
Now you are into this section i presume you have already ran all commands from before because those are really important for the correct functionality and for sure the commands related to setting up and loading the tuya specific binary environment correctly and loading drivers because otherwise you get a kernel panic or crashes (I had it crash when i forgot to do so). If not, please follow the instructions in: [Earlier section](#Mounting-and-preparing-the-environment-for-the-Tuya-stuff)


With all the programs being a symlink to the main doraemon binary, it made me curious so i ran some programs. I also found [THIS](https://raw.githubusercontent.com/RX309Electronics/LSC_Indoor_camera/main/secret_message) easteregg by the developers that pops up when i run some programs. Quite a fun easteregg and i never really seen many devices have many eastereggs or any at all by the software devs. assitant_voice is the program for playing audio and it gives this when i ran it with no arguments it asked for a media_file parameter and a volume and gain parameter. I quickly found out i could play audio using this program. I first tested it with the audio files in the /usr/local/resource/assistant_voice directory and it worked! Below is a quick snippet you can try:
```
assistant_voice /usr/local/resource/assistant_voice/effect_sound1.mp3 10 10
```

Next i thought "It can play mp3 files...... Maybe i can play music from the sdcard through the speaker usig this audio daemon process...."
So i thought 'Lets try never gonna give you up first' so i downloaded the mp3 file and then converted it using the below command on my host system to the correct format and bitrate:
```
ffmpeg -i nggyu.mp3 -ar 16000 -ac 1 -b:a 40k -c:a libmp3lame nggyu_converted.mp3
```

Then copy it to the sdcard:
```
cp nggyu_converted.mp3 {sdcard directory. Change this to where the sdcard is mounted}/nggyu.mp3
```

Then i ejected the sdcard from my host pc and plugged it into the camera. Then i mounted it via the userland to a read-write directory, /tmp/sdcard using below commands:
```
mkdir /tmp/sdcard
mount /dev/mmcblk0p1 /tmp/sdcard
```

Then its as simple as executing below command. I am still figuring out how to set the volume though but below snippet plays it at a reasoanble volume:
```
assistant_voice /tmp/sdcard/nggyu.mp3 volume=0 
```
 



