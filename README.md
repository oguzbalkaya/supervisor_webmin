# Webmin Module for Supervisor

Start, stop and reload Supervisor.

Edit main configurations.

Create subprocesses with form or manually.

Start, stop, restart, tail and clear log subprocesses.

Create groups.

Start and stop groups.

Manage multiple supervisors from the same place.

## Updates

- **21.08.2022**

"Check node status" button has been added.  The module won't always check the connection of nodes. If you want to check the connections, you need to click the button. If you enter the "All nodes in one page" section, you will only see the nodes that were connected the last time you clicked the "Check node status" button.


## Installation

Download supervisor.wbm.gz file from this repository ([or click to download](https://oguzbalkaya.net.tr/supervisor.wbm.gz)).

Go "Webmin Main Menu > Webmin Configuration > Webmin Modules > Install > From uploaded file" and install module.

You can install supervisor from the module or you can review it from [here](http://supervisord.org/). 

## If you need more information about the module, you can read my article about the module from [here](https://www.oguzbalkaya.com.tr/2022/05/webmin-module-for-supervisor.html).

## Requirements

Perl modules RPC::XML and RPC::XML:Client is required for managing multiple supervisors.

## License
[GPL](https://www.gnu.org/licenses/gpl-3.0.tr.html)


## Screenshots

![index](https://user-images.githubusercontent.com/44072450/161348008-e1dbb6a8-2694-405f-a3ad-4b49e11caf1f.png)

![edit_manual](https://user-images.githubusercontent.com/44072450/161348022-265e5ace-44a9-4220-877b-0873c3d45c5c.png)

![edit_manual2](https://user-images.githubusercontent.com/44072450/161348031-f4a30f88-2e80-4498-9afa-e518c7614d52.png)

![create_subprocess](https://user-images.githubusercontent.com/44072450/161348056-13e38219-1023-437a-a5c3-62756ee09349.png)

![create_subprocess_manually](https://user-images.githubusercontent.com/44072450/161348072-e2777a52-7c91-4e34-8c5f-c1ac4a1d8c02.png)

![create_group](https://user-images.githubusercontent.com/44072450/161348094-1b369bb6-b932-482a-aabd-05e41903075d.png)

![nodes](https://user-images.githubusercontent.com/44072450/185803171-6e2b14cb-2893-48da-a354-1214fcedbd99.png)

![node_details](https://user-images.githubusercontent.com/44072450/161348164-4de986ca-56b2-4160-970b-059af7a3c8c5.png)

![all_nodes_one_page](https://user-images.githubusercontent.com/44072450/161348123-2e5dbfa8-4001-44b5-a3ae-e38e0820d565.png)

![read_stdout](https://user-images.githubusercontent.com/44072450/161348130-3a6a1e01-7299-4473-bfa6-ee0407de4587.png)

![tail_stdout](https://user-images.githubusercontent.com/44072450/161348139-ace4455b-fb16-4db5-af12-df30e85cb7e5.png)
