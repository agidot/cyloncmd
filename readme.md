# Installation Guide

###For Mac OSX
1.Install [Homebrew] package manager by following command.
```sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
2.After installation completed run following commands to check system and update homebrew.
```sh
$ brew doctor
$ brew update
```
3.Install [Node JS] on your machine ([npm], Node Package Manager, will be installed with Node JS)
```sh
$ brew install node
```
4.Next, install [Bower] (the package manager for web)
```sh
$ npm install -g bower
```
5.Clone (or download zip) **cyloncmd** to your machine
6.Nevigate to **cyloncmd** project directory
7.Get all dependency packages by running following commands
```sh
$ npm install
$ bower install
```
8.Start chrome and enter url 'chrome://extensions/'
9.Make sure Developer mode is checked
10.Click 'Load unpacked extension...' button then select the **cyloncmd** project directory

[Node JS]:http://nodejs.org
[Homebrew]:http://brew.sh/
[Bower]:http://bower.io/
[npm]:https://www.npmjs.org/