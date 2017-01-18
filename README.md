->![logo](http://is1.mzstatic.com/image/thumb/Purple5/v4/c8/f1/a8/c8f1a89d-ef1a-86ad-abf6-bb3eced1c465/source/175x175bb.jpg "App Store Icon")<-
# LaundryView
An iOS mobile application that tracks the laundry machines in the student dormitories at Wake Forest University.

[View in iTunes App Store](https://itunes.apple.com/us/app/wfu-laundryview/id431321503?mt=8)

### Setup

This application connects to an API server that handles the data of each laundry machine. Each laundry machine is connected to the Internet with a peice of hardware that can send the following information:

	* Machine number

	* Machine status (running, empty, disabled)

	* Time remaining for current process (running state)

### API

The links for the API are setup so that there is one master XML file that lists all the dorms. This file can be found [here](http://api.laundryview.com/school/?api_key=8c31a4878805ea4fe690e48fddbfffe1&method=getRoomData). With each dorm location, there is an ID number associated with it. Those ID numbers can be used to navigate to that dorm's XML file to get information about that dorm's laundry room. The format of that URL is:

```
http://api.laundryview.com/room/?api_key=8c31a4878805ea4fe690e48fddbfffe1&method=getAppliances&location={DORM ID HERE}
```

### Push Notifications

Push notifications were implemented in the app to alert the user when their laundry is about to be complete. If the user selects a running laundry machine as theirs, it will notify them 5 minutes before their laundry is complete. That way they have enough time to get to the laundry room before someone dumps out their laundry onto the floor.

### User Flow

* On first load, the app essentially checks to see if there is a settings txt file set on the user's device. If there isn't it asks what dorm the user lives in.

* After the user selects a dorm, the app saves the user's selection to a settings txt file to remember the user's preferences.

* The app then loads a view of laundry machines for that user's dorm.

### License

Feel free to fork this repository for educational purposes or to implement a similar solution at another university.

