# LSC_Indoor_camera
In this repo i will share some files and scripts of my adventure in hardware hacking a LSC indoor camera from Action. 

# Story
I am in my hardwarehacking phase where i buy or get embedded devices like routers, cameras, tv setopboxes and other consumer devices where i explore and find vulnerabilities and just how its build up. I like this because you can learn a lot from those devices and the thought and engineering process behind them. And its fun to hook into the serial ports on those devices and see what is going on behind the scenes. 
I bought this camera at Action yesterday (Action is a german dutch store that sells all sorts of things for a cheap price) because i thought 'This might run embedded linux" And i was right! I opened it up and started looking for a serial port which i quickly found and i attached my usb to uart converter to to see if i can view the device logs. I also wanted to look at the security of these devices because they are cheap and are usually just Tuya gear thats rebranded and Tuya is chinese and IOT has been know for its Insecurity (Its where the 'I' in IOT stands for :) ). I connected it to the app first to see if everything was functioning and then i started my adventure. 

# The device itself
![1000179976](https://github.com/user-attachments/assets/aaf8a048-2327-4080-abb7-1935c3606eec)

![1000179977](https://github.com/user-attachments/assets/20d43b8e-94a3-405b-ae03-0f865bdbbb2e)

![1000179978](https://github.com/user-attachments/assets/bbf84f3f-00db-4c68-a106-54fb96eff541)

![1000179980](https://github.com/user-attachments/assets/a68bf4c5-1f08-46c2-8c72-576620a57792)

As you can see, you have to pry it open at the front. Stick a spudger or screwdriver between the edge and the black front plastic and then it should pop off. 
Once inside you can see the main components: 
![1000179981](https://github.com/user-attachments/assets/915324e0-cba0-4730-9553-00cbbb5134b7)
The main soc of the camera is a Ingenic T23N. This chip is quite beefy:
![image](https://github.com/user-attachments/assets/84f89b41-a1fb-4083-8087-2f9241c109d2)
