#!/usr/bin/env bash

# exit on any error
set -Ee

# Enter the directory that contains this script file
cd $(dirname $0)
TOP=$( pwd -L )

if [ $(id -u) -eq 0 ] ; then
    echo "This script should not be run as root or with sudo."
    return 1
fi

# function to display menus
show_menus() {
    clear
    echo "                     "
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo " WELCOME TO MYCROFT GUI INSTALLATION SCRIPT "
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "                     "
    echo "Please Note: This is an Interactive script that will take you through a series of installation choices, where you might be required to provide your administrative password to successfully install system dependencies and Mycroft GUI on your system."
    echo "                     "
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo " SELECT - DISTRIBUTION "
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo "1. KDE NEON"
    echo "2. K/UBUNTU 20.04+"
    echo "3. MANJARO/ARCH"
    echo "4. OTHERS"
    echo "5. UPDATE INSTALLATION"
    echo "6. EXIT"
}

read_options() {
    echo " "
	local choice
	read -p "Enter choice [ 1 - 5 ] " choice
	case $choice in
		1) neon ;;
		2) kubuntu ;;
		3) manjaro ;;
		4) others ;;
		5) updateinstall;;
		6) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}

#trap '' SIGINT SIGQUIT SIGTSTP

function found_exe() {
   hash "$1" 2>/dev/null
}

neon() {
    echo "Starting Installation For KDE NEON"
    echo ""
    echo "Following Packages Will Be Installed: git-core g++ cmake extra-cmake-modules kio-dev gettext pkg-config qml-module-qtwebengine pkg-kde-tools qtbase5-dev qtdeclarative5-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev libkf5plasma-dev libkf5kio-dev libqt5webview5-dev"
    echo ""
    echo "Please Enter Authentication For Installing System Dependencies"
    sudo apt-get install -y git-core g++ cmake extra-cmake-modules kio-dev gettext pkg-config qml-module-qtwebengine pkg-kde-tools qtbase5-dev qtdeclarative5-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev libkf5plasma-dev libkf5kio-dev libqt5webview5-dev
    build_gui
}

kubuntu() {
    echo "Starting Installation For K/Ubuntu 20.04 +"
    echo ""
    echo "Following Packages Will Be Installed: git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev libkf5plasma-dev libqt5webview5-dev"
    echo ""
    echo "Please Enter Authentication For Installing System Dependencies"
    sudo apt-get install -y git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev libkf5plasma-dev libqt5webview5-dev
    build_gui
}

manjaro() {
    echo "Starting Installation For Manjaro / Arch"
    echo ""
    echo "Following Packages Will Be Installed: cmake extra-cmake-modules kio kio-extras plasma-framework qt5-websockets qt5-webview qt5-declarative qt5-multimedia qt5-quickcontrols2 qt5-webengine qt5-base"
    echo ""
    echo "Please Enter Authentication For Installing System Dependencies"
    yes | sudo pacman -S git cmake extra-cmake-modules kio kio-extras plasma-framework qt5-websockets qt5-webview qt5-declarative qt5-multimedia qt5-quickcontrols2 qt5-webengine qt5-base
    build_gui   
}

updateinstall() {
    echo "Pulling Latest Changes From Master"
    git pull origin master
    echo "Update Completed"
    exit 0
}

continue_unknown() {
    echo "Starting Installation For Unknown Platform, Builds Will Fail If Required Packages Are Not Found"
    build_gui
}

return_previous() {
    show_menus
}

others () {
      clear
      echo "You must manually install the following packages for this platform"
      echo "cmake extra-cmake-modules kio kio-extras plasma-framework qt5-websockets qt5-webview qt5-declarative qt5-multimedia qt5-quickcontrols2 qt5-webengine qt5-base"
      echo "Consider contributing support for your platform by adding it to this script"
      
      echo "1. Continue Installation"
      echo "2. Return To Previous Menu"
      echo "3. Exit"
      
      local additional_choice
      read -p "Enter choice [ 1 - 3 ] " additional_choice
      case $additional_choice in
          1) continue_unknown;;
          2) return_previous;;
          3) exit 0;;
      esac
}

function build_gui() {
    echo " "
    echo "Building Mycroft GUI"
    if [[ ! -d build-testing ]] ; then
    mkdir build-testing
    fi
    cd build-testing
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
    make -j4
    sudo make install
    install_lottie
}

function install_lottie() {
    echo " "
    echo "Installing Lottie-QML"
    cd $TOP
    if [[ ! -d lottie-qml ]] ; then
        git clone https://github.com/kbroulik/lottie-qml
        cd lottie-qml
        mkdir build
    else
        cd lottie-qml
        git pull
    fi

    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
    make
    sudo make install
    complete_installer
}   

function complete_installer() {
    echo " "
    if [[ ! -f /etc/mycroft/mycroft.conf ]] ; then
        if [[ ! -d /etc/mycroft ]] ; then
            sudo mkdir /etc/mycroft
        fi

cat <<EOF | sudo tee /etc/mycroft/mycroft.conf 
{
    "enclosure": {
        "platform": "mycroft_mark_2"
    }
}
EOF

    fi
    
    if [[ -f /etc/mycroft/mycroft.conf ]] ; then
        echo "Found an existing Mycroft System Level Configuration at /etc/mycroft/mycroft.conf"
        echo "Please add the following enclosure settings manually to existing configuration to ensure working setup:"
        echo " "
        echo '"enclosure": {'
        echo '     "platform": "mycroft_mark_2"'
        echo '}'
        echo ""
    fi    
    echo "Installation complete!"
    echo "To run, invoke:  mycroft-gui-app"
    exit 0
}

while true
do

	show_menus
	read_options
done
