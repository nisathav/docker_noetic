#FROM osrf/ros:noetic-desktop-full
# Use an official CUDA runtime as a parent image
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04
# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
# Install ROS Noetic
RUN apt-get update && apt-get install -y lsb-release gnupg2 curl && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt-get update && apt-get install -y ros-noetic-desktop-full
# Install Arduino IDE dependencies
RUN apt-get update && \
    apt-get install -y \
    openjdk-11-jdk \
    gcc-avr \
    avr-libc \
    && rm -rf /var/lib/apt/lists/*
# Download and install Arduino IDE
RUN curl -fsSL https://downloads.arduino.cc/arduino-1.8.19-linux64.tar.xz -o /tmp/arduino.tar.xz && \
    tar -xvf /tmp/arduino.tar.xz -C /opt && \
    rm /tmp/arduino.tar.xz && \
    ln -s /opt/arduino-1.8.19 /opt/arduino
# Add Arduino to PATH
ENV PATH=$PATH:/opt/arduino/
# Example of installing programs
RUN apt-get update \
    && apt-get install -y \
    python3-pip \
    python3-argcomplete \
    python3-rosdep \
    ros-noetic-pointcloud-to-laserscan \
    nano \
    ros-noetic-gazebo-ros \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-gazebo-dev \
    ros-noetic-gazebo-ros \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-ros-control \
    ros-noetic-ros-controllers \
    ros-noetic-gazebo-ros-control \
    ros-noetic-hardware-interface \
    ros-noetic-xacro \
    python3-matplotlib \ 
    python3-pyqtgraph \
    vim \
    ros-noetic-rviz \
    ros-noetic-moveit \
    ros-noetic-cv-bridge \
    curl \
    libgflags-dev \
    libsdl-dev \ 
    libsdl-image1.2-dev \
    ros-noetic-tf2-sensor-msgs \
    ros-noetic-move-base-msgs \
    build-essential \
    ros-noetic-rosparam-shortcuts \
    #yolov7
    ros-noetic-vision-msgs \
    ros-noetic-rosserial \
    ros-noetic-rosserial-arduino \
    ros-noetic-rosserial-python \
    apt-transport-https \
    ros-noetic-teleop-twist-joy \
    ros-noetic-teleop-twist-keyboard \ 
    ros-noetic-velodyne-simulator \
    #SLAM
    ros-noetic-navigation \
    ros-noetic-gmapping \
    ros-noetic-map-server \
    ca-certificates \
    gnupg \
    can-utils \
    iproute2 \
    libmuparser-dev \
    #realsense camera
    ros-noetic-realsense2-camera \
    ros-noetic-realsense2-description \
    ros-noetic-robot-localization \
    ros-noetic-twist-mux \
    ros-noetic-interactive-marker-twist-server \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*
# Set environment variables
#ENV GAZEBO_MASTER_URI http://localhost:11345
# Install Visual Studio Code
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code
RUN pip3 install torch torchvision torchaudio opencv-python seaborn thop requests tqdm pyyaml scipy python-can transformers spacy timm einops 
RUN pip3 install --upgrade numpy pandas scipy
# Install librealsense
# RUN apt-get update && apt-get install -y \
#     libssl-dev \
#     libusb-1.0-0-dev \
#     libudev-dev \
#     pkg-config \
#     libgtk-3-dev \
#     libglfw3-dev \
#     libgl1-mesa-dev \
#     libglu1-mesa-dev \
#     at \
#     && rm -rf /var/lib/apt/lists/*
# RUN git clone https://github.com/IntelRealSense/librealsense.git \
#     && cd librealsense \
#     && mkdir build && cd build \
#     && cmake ../ -DCMAKE_BUILD_TYPE=Release \
#     && make -j4 \
#     && make install
# Example of copying a file
#USER root
#COPY mangobee_robot/ /mangobee_robot
# Create a non-root user
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config
# Set up sudo
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*
#Programs for testing devices
RUN apt-get update \
    && apt-get install -y \
    evtest \
    jstest-gtk \
    python3-serial \
    && rm -rf /var/lib/apt/lists/*
    
# Install spaCy English model
RUN python3 -m spacy download en_core_web_sm    
# Copy the entrypoint and bashrc scripts so we have 
# our container's environment set up correctly
COPY entrypoint.sh /entrypoint.sh
COPY bashrc /home/${USERNAME}/.bashrc
# Expose ports for Gazebo and RViz
EXPOSE 11345
EXPOSE 9090
# Set up entrypoint and default command
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["bash"]
