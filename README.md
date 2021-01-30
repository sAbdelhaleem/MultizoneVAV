# MultizoneVAV
This is the software repository of a testbed for evaluating the performance of advanced control sequences of operation for heating, ventilating, and air conditioning (HVAC) air distribution and terminal systems. The testbed was developed with the Modelica modeling language to simulate the performance of a building model with a multiple zone variable air volume (VAV) system, programmed with advanced control sequences.

The testbed was developed to evaluate issues related to system design and control component selection, and performance sensitivity to various control-related parameters in [[1]](#1). In particular, the tesbed was used to implement two studies to evaluate the control sequence performance for system outputs of thermal comfort, indoor air quality (IAQ), and site electricity use. The first study quantified the effect of different levels of uncertainty in the control components (e.g. sensors and actuators) on system performance, and investigated how uncertainty can be incorporated in the specification and selection of components [[2]](#2). The primary focus of the second study was to aid in prioritization of control loops according to their importance to the system outputs. In turn, this can be used to better prioritize control problems with high impact on system outputs over retuning control loops where the impact of poor performance on system outputs is small. The second study also implemented an assessment of individual control loop performance using the Harris index, and described procedures to correctly customize the index parameters to every installation [[3]](#3).

The multiple zone VAV system model was programmed with ASHRAE Guideline 36 (G36) – High-Performance Sequences of Operation for HVAC Systems, which describes advanced sequences of operation for common HVAC systems [[4]](#4). A two-zone model was developed and then coupled to a software implementation of G36 sequences of operation applicable to the building. The building thermal model was developed using technical specifications collected from a real-world typical medium office building located in State College, PA. The numbering of the zones in the real-world application (i.e., zone 406 and zone 222) was used to refer to the thermal zones in this testbed.

Simulations were implemented using JModelica version 2.1 textual simulation environment compiled on an Ubuntu 16.04.4 LTS distribution. The testbed was developed using component models from the Modelica Buildings Library (MBL), which is an open-source library that contains component models that can be modified if necessary and then used to produce system models for dynamic simulation [[5]](#5). The models were built based on the structure of the OpenBuildingControl (OBC) example application for the G36 in a multiple zone VAV system [[6]](#6). The OBC project is intended to develop tools and processes for the performance evaluation, specification, deployment and verification of building control sequences. The models for the OBC example is maintained in the open-source MBL. We introduced adjustments and new models customized to the research objectives in [[1]](#1). For example, to perform model-based uncertainty quantification, we introduced new stochastic models using the open-source Modelica noise sub-library [[7]](#7) that is maintained in the Modelica Standard Library (MSL) [[8]](#8). For the detailed description of the MBL component models, before being adjusted for this testbed, the reader is referred to the model documentation in [[9]](#9).

If you use this testbed, we would appreciate citations to Abdel Haleem et al. [[10]](#10) which describes the development of the tesbed with the ability to simulate the influence of the uncertainty inherent in the HVAC control components (e.g. sensors and actuators) on system outputs.

The organization of this README file is as follows: [Section 1](#Section1) describes a customized procedure for compiling JModelica from sources on Ubuntu; and [Section 2](#Section2) describes the installation procedure for MultizoneVAV and its dependencies on Ubuntu. If you have already installed JModelica on your operating system, you can skip Section 1. It is worth pointing out, that MultizoneVAV was installed successfully on Red Hat Enterprise Linux (RHEL) version 6, however, it was not tested on a windows operating system. In addition, MultizoneVAV was not tested with simulation environments other than JModelica, e.g., MultizoneVAV was not tested with Dymola.

# <a name="Section1"></a>1. Compiling JModelica from sources on Ubuntu
This section describes a customized procedure for compiling JModelica from sources on Ubuntu. The original installation procedure is provided in *JModelica User Manual 2.1*, however, since the time this testbed was developed JModelica.org discontinued providing direct access to the user manual. The reader may refer to the installation procedure in *JModelica User Manual 2.2* at the following [link](https://jmodelica.org/downloads/UsersGuide.pdf). It is worth pointing out that, the installation of JModelica is sensitive to the dependencies versions, i.e., the specific package version for the dependencies may be different between JModelica 2.1 and 2.2. The customized step-by-step installation procedure is assigned to one master numbering sequence (represented as **bold numbering**).

**1.** Download *ubuntu-16.04.4-desktop-amd64.iso* from the old Ubuntu releases webpage at the following [link](http://old-releases.ubuntu.com/releases/xenial/).

**2.** Perform a fresh installation of Ubuntu. In the installation prcedure check the radio buttons next to "download updates while installing", and "install third-party software …"

**3.** Install the JModelica dependencies using the command lines shown in Code Block 1, each with the specific package version.

Code Block 1: Installation of JModelica dependencies using specific package version.
~~~
sudo apt-get -y install python-dev=2.7.12-1~16.04
sudo apt-get -y install python-setuptools=20.7.0-1
sudo apt-get -y install cmake=3.5.1-1ubuntu3
sudo apt-get -y install gfortran=4:5.3.1-1ubuntu1
sudo apt-get -y install ipython=2.4.1-1
sudo apt-get -y install swig=3.0.8-0ubuntu3
sudo apt-get -y install ant=1.9.6-1ubuntu1.1
sudo apt-get -y install python-numpy=1:1.11.0-1ubuntu1
sudo apt-get -y install python-pip=8.1.1-2ubuntu0.6
pip install 'scipy==0.18.0'
sudo apt-get -y install python-matplotlib=1.5.1-1ubuntu1
sudo apt-get -y install cython=0.23.4-0ubuntu5
sudo apt-get -y install python-lxml=3.5.0-1ubuntu0.3
sudo apt-get -y install python-nose=1.3.7-1
sudo apt-get -y install python-jpype=0.5.4.2-3
sudo apt-get -y install libboost-dev=1.58.0.1ubuntu1
sudo apt-get -y install jcc=2.21-1.1
sudo apt-get -y install subversion=1.9.3-2ubuntu1.3
sudo apt-get -y install zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.3
~~~

**4.** Setup the Java environment variable using the command lines shown in Code Block 2.

Code Block 2: Setup the Java environment variable.
~~~
$ sudo gedit /etc/environment

# On a new line in the /etc/environment file, add the following
# JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
# Press the save button and close the file

$ source /etc/environment
$ echo $JAVA_HOME
~~~
Note: Add the environment variable without the hashtag. echo $JAVA_HOME should return the Java directory path.

**5.** Download the main packages for the installation as listed in Table 1, each with the specific package version.

**Table 1:** Procedure to download the main packages for JModelica.
| Package  | Version | Download Link |
| ------------- | ------------- | ------------- |
|  Ipopt  |  3.12 (revision 2778)  |  checkout the source files from the subversion repository using the command lines in Code Block 3 |
|  Third party dependencies for Ipopt  |  -  |  download the dependencies using the command lines shown in Code Block 4  |
|  HSL for Ipopt <sup>a</sup>  |  coinhsl v2015.06.23  |  request personal licence from HSL at the following [link](http://www.hsl.rl.ac.uk/ipopt/)  |
|  JModelica  |  2.1 (r10720)  |  request public open source version from JModelica.org <sup>b</sup>  |

<sup>a</sup> HSL provides a number of linear solvers that can be used in Ipopt. For the reader reference, the command lines to include the HSL package in Ipopt are shown in Code Block 5, however, HSL solvers were not used to simulate this testbed.
<sup>b</sup> At the time this testbed was developed, JModelica source files were checked out from the subversion repository. However, checking out JModelica was associated with an error during checkout of the Assimulo simulation package. This was resolved by checking out the Assimulo source files in a separate checkout command from the JModelica checkout command. This is worth being pointed out so that the reader ensures the JModelica source files supplied by JModelica.org includes Assimulo. For the reader reference, the command lines to checkout JModelica and Assimulo are shown in Code Block 6, however, since the time this testbed was developed JModelica.org discontinued providing direct access to the source files from the links in Code Block 6. It is also worth pointing out that, JModelica source files include Modelica Standard Library 3.2.2, which is a prerequisite to simulate this testbed.

Code Block 3: checking out Ipopt source files from the subversion repository.
~~~
$ cd ~
$ svn co https://projects.coin-or.org/svn/Ipopt/stable/3.12 Ipopt
~~~
Note: This will download Ipopt source files (revision 2778) in the ~/Ipopt directory.

Code Block 4: Downloading third party dependencies for Ipopt.
~~~
$ cd ~/Ipopt/ThirdParty/Blas
$ ./get.Blas
$ cd ../Lapack
$ ./get.Lapack
$ cd ../Mumps
$ ./get.Mumps
$ cd ../Metis
$ ./get.Metis
~~~

Code Block 5: Copying HSL source files into the ~/Ipopt/ThirdParty/HSL directory, and renaming the directory.
~~~
# Copy coinhsl-2015.06.23.tar.gz from the download directory to the home directory
$ cd ~
$ mv coinhsl-2015.06.23.tar.gz ~/Ipopt/ThirdParty/HSL
$ cd ~/Ipopt/ThirdParty/HSL
$ tar xf coinhsl-2015.06.23.tar.gz
$ mv coinhsl-2015.06.23 coinhsl
$ rm coinhsl-2015.06.23.tar.gz
~~~
Note: Download link for *coinhsl-2015.06.23.tar.gz* is provided by the HSL team upon their approval of the personal licence request.

Code Block 6: checking out JModelica and Assimulo source files from the subversion repository at the time this testbed was developed.
~~~
$ cd ~
$ svn co https://svn.jmodelica.org/trunk JModelica
$ cd ~/JModelica/external
$ svn co https://svn.jmodelica.org/assimulo/trunk Assimulo
~~~

**6.** Install Ipopt using the command lines shown in Code Block 7.

Code Block 7: Ipopt installation.
~~~
$ sudo mkdir /opt/Ipopt
$ mkdir ~/Ipopt/build
$ cd ~/Ipopt/build
$ ../configure --prefix=/opt/Ipopt
$ sudo make install
~~~

**7.** Install JModelica using the command lines shown in Code Block 8.

Code Block 8: JModelica installation.
~~~
# Copy JModelica source files from the download directory to the home directory
$ sudo mkdir /opt/JModelica
$ mkdir ~/JModelica/build
$ cd ~/JModelica/build
$ ../configure --prefix=/opt/JModelica --with-ipopt=/opt/Ipopt
$ sudo make install
$ sudo make casadi_interface
~~~
Note: Download link for *JModelica* source files with Assimulo source files included in JModelica/external/Assimulo are provided by the JModelica team upon their approval of the JModelica 2.1 (r10720) public open source version request.

**8.** Setup the JModelica environment variable using the command lines shown in Code Block 9.

Code Block 9: Setup the JModelica environment variable.
~~~
$ sudo gedit /etc/environment

# On a new line in the /etc/environment file, add the following
# JMODELICA_HOME="/opt/JModelica"
# Press the save button and close the file

$ source /etc/environment
$ echo $JMODELICA_HOME
~~~
Note: Add the environment variable without the hashtag. echo $JMODELICA_HOME should return the JMODELICA_HOME directory path.

**9.** Import and run the examples built-in JModelica to test the installation using the command lines shown in Code Block 10.

Code Block 10: Testing JModelica.
~~~
$ $JMODELICA_HOME/bin/jm_ipython.sh
$ mkdir ~/TestingJModelica
$ cd ~/TestingJModelica

# Import and run the fmi_bouncing_ball example and plot results
$ from pyfmi.examples import fmi_bouncing_ball
$ fmi_bouncing_ball.run_demo()

# Import and run the CSTR example using CasADi and plot results
$ from pyjmi.examples import cstr_casadi
$ cstr_casadi.run_demo()

# Import and run the RLC example and plot results
$ from pyjmi.examples import RLC
$ RLC.run_demo()

$ exit
$ cd ~
$ rm -r ~/TestingJModelica
~~~
Note: The simulation will plot the results in separate pop-up windows, close the window for the simulation to continue.

# <a name="Section2"></a>2. Installation of MultizoneVAV
The installation of MultizoneVAV requires the installation of *Modelica Standard Library 3.2.2* , which is included with JModelica source files as discussed above, and *Modelica Buildings Library 5.0.1*. The step-by-step installation of MultizoneVAV and its dependencies continues the master numbering sequence presented in [Section 1](#Section1) (represented as **bold numbering**).

**10.** Download *Buildings-v5.0.1.zip* from the all releases of the MBL webpage at the following [link](https://simulationresearch.lbl.gov/modelica/downloads/archive/modelica-buildings.html).

**11.** Copy *Buildings-v5.0.1.zip* to the home directory and install MBL using the command lines shown in Code Block 11. The original procedure to install MBL is provided at the following [link](https://simulationresearch.lbl.gov/modelica/installLibrary.html).

Code Block 11: Installation of MBL.
~~~
$ cd ~
$ unzip Buildings-v5.0.1.zip
$ rm Buildings-v5.0.1.zip
$ sudo mkdir -p /usr/local/Modelica/Library/Buildings_5.0.1
$ sudo mv ~/Buildings\ 5.0.1 /usr/local/Modelica/Library/Buildings_5.0.1
~~~

**12.** Download *MultizoneVAV-master.zip* from the code button, download ZIP provided in this repository webpage at the following [link](https://github.com/sAbdelhaleem/MultizoneVAV).

**13.** Copy *MultizoneVAV-master.zip* to the home directory and install MultizoneVAV using the command lines shown in Code Block 12.

Code Block 12: Installation of MultizoneVAV.
~~~
$ cd ~
$ unzip MultizoneVAV-master.zip
$ rm MultizoneVAV-master.zip
$ mv MultizoneVAV-master MultizoneVAV_0.1.0
$ sudo mv ~/MultizoneVAV_0.1.0 /usr/local/Modelica/Library
~~~

**14.** Setup the MSL, MBL, and MultizoneVAV environmental variables using the command lines shown in Code Block 13.

Code Block 13: Setup the MSL, MBL, and MultizoneVAV environmental variables.
~~~
$ sudo gedit /etc/environment

# On a new line in the /etc/environment file, add the following
# MODELICAPATH="/opt/JModelica/ThirdParty/MSL:/usr/local/Modelica/Library/Buildings_5.0.1:/usr/local/Modelica/Library/MultizoneVAV_0.1.0"
# Press the save button and close the file

$ source /etc/environment
$ echo $MODELICAPATH

# Restart the computer
~~~
Note: Add the environment variable without the hashtag. As noted earlier, Modelica Standard Library 3.2.2 is installed with JModelica source files, thus, MSL directory path is located within the JModelica directory. echo $MODELICAPATH should return the MODELICAPATH directory paths.

**15.** Install pandas for data manipulation and analysis using the command line shown in Code Block 14, with the specific package version. pandas is not a prerequisite to install MultizoneVAV, however, it is used below to work with time series data.

Code Block 14: Installing pandas.
~~~
pip install 'pandas==0.23.4'
~~~

**16.** Simulate MultizoneVAV example to test the installation using the command lines shown in Code Block 15 to test the installation.

Code Block 15: Testing MultizoneVAV.
~~~
$ $JMODELICA_HOME/bin/jm_ipython.sh

$ mkdir ~/TestingMultizoneVAV
$ cd ~/TestingMultizoneVAV

$ run /usr/local/Modelica/Library/MultizoneVAV_0.1.0/MultizoneVAV\ 0.1.0/Simulation/UncertaintyModels/Guideline36.py

$ exit
$ cd ~
$ rm -r ~/TestingMultizoneVAV
~~~
Note: This will simulate the MultizoneVAV system for one hour during Jan 8 from 7:00 AM to 8:00 AM.

# References
<a name="1"></a>[1]	S. M. Abdel Haleem, "Impact of Component Uncertainty and Control Loop on Performance in HVAC Systems with Advanced Sequences of Operation," Doctor of Philosophy, Architectural Engineering, The Pennsylvania State University, 2020. Accessed: Jan 08, 2021. [Online]. Available: https://etda.libraries.psu.edu/catalog/17584sma282.

<a name="2"></a>[2]	S. M. Abdel Haleem, G. S. Pavlak, and W. P. Bahnfleth, "Performance of advanced control sequences in handling uncertainty in energy use and indoor environmental quality using uncertainty and sensitivity analysis for control components," Energy and Buildings, vol. 225, p. 110308, 2020, doi: https://doi.org/10.1016/j.enbuild.2020.110308.

<a name="3"></a>[3]	S. Abdel Haleem, G. Pavlak, and W. Bahnfleth, “Impact of Control Loop Performance on Energy Use, Air Quality, and Thermal Comfort in Building Systems with Advanced Sequences of Operation,” Automation in Construction. (Under Review)

<a name="4"></a>[4]	Guideline 36-2018 High-Performance Sequences of Operation for HVAC Systems, American Society of Heating Refrigeration and Air-Conditioning Engineers, Atlanta, GA, USA, 2018. Accessed: Sep 7, 2020. [Online]. Available: https://www.techstreet.com/ashrae/standards/guideline-36-2018-high-performance-sequences-of-operation-for-hvac-systems?product_id=2016214

<a name="5"></a>[5]	M. Wetter, Z. Wangda, T. S. Nouidui, and P. Xiufeng, "Modelica Buildings library," Journal of Building Performance Simulation, vol. 7, no. 4, pp. 253-270, 2014, doi: http://dx.doi.org/10.1080/19401493.2013.765506.

<a name="6"></a>[6]	M. Wetter, J. Hu, M. Grahovac, B. Eubanks, and P. Haves, "OpenBuildingControl: Modeling feedback control as a step towards formal design, specification, deployment and verification of building control sequences," Building Performance Analysis Conference and SimBuild, 2018. Accessed: Jan 10,2021. [Online]. Available: https://www.ashrae.org/File%20Library/Conferences/Specialty%20Conferences/2018%20Building%20Performance%20Analysis%20Conference%20and%20SimBuild/Papers/C107.pdf.

<a name="7"></a>[7]	Modelica Noise library. (2015). German Aerospace Center (DLR). Accessed: Jan 08, 2021. [Online]. Available: https://github.com/DLR-SR/Noise

<a name="8"></a>[8]	Modelica Standard Library, 3.2.2+build.3 ed., (04/03/2016). Modelica Association. Accessed: Nov 23, 2020. [Online]. Available: https://github.com/modelica/ModelicaStandardLibrary/releases/tag/v3.2.2

<a name="9"></a>[9]	Modelica Buildings Library: Model Documentation, 5.0.1 ed., (11/22/2017). Lawrence Berkeley National Laboratory (LBNL). Accessed: Jan 08, 2021. [Online]. Available: https://simulationresearch.lbl.gov/modelica/releases/v5.0.1/help/Buildings.html

<a name="10"></a>[10]	S. Abdel Haleem, G. Pavlak, and W. Bahnfleth, “Model-based Testbed for Uncertainty Quantification in Building Control Systems with Advanced Sequences of Operation,” Journal of Building Performance Simulation. (Under Review)

# License & copyright
**1.** MultizoneVAV

Copyright (c) 2021 Shadi Abdel Haleem

MultizoneVAV is provided as free software under the terms of the GNU General Public License (GNU GPL). Redistribution and use, with or without modification, are permitted with any express or implied warranties, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. For the terms of the GNU GPL, please refer to http://www.gnu.org/licenses

**2.** Modelica Buildings Library
MultizoneVAV includes source code from the Modelica Buildings Library (MBL) with modification. Accordingly, following is the MBL license.

Modelica Buildings Library. Copyright (c) 1998-2020 Modelica Association, International Building Performance Simulation Association (IBPSA), The Regents of the University of California, through Lawrence Berkeley National Laboratory (subject to receipt of any required approvals from the U.S. Dept. of Energy) and contributors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the names of the Modelica Association, International Building Performance Simulation Association (IBPSA), the University of California, Lawrence Berkeley National Laboratory, U.S. Dept. of Energy, nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

**3.** Modelica Standard Library
MultizoneVAV includes source code from the Modelica Standard Library (MSL) with modification. Accordingly, following is the MSL license.

Copyright (c) 1998-2020, Modelica Association and contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
