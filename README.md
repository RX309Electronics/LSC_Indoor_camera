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

After i did that and started a terminal session on my pc, I could view the logs. I am on Debian Linux so i use picocom but you can use putty or minicom if you desire. 
https://github.com/RX309Electronics/LSC_Indoor_camera/blob/main/bootlog.txt




