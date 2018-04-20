Project to create a docker image for Jupyter Notebook editor tailored for xp team.

Image is based on docker hub anaconda image with python 2.7.
Anaconda comes with the following packages installed:

https://docs.anaconda.com/anaconda/packages/py3.6_linux-64

On top of Anaconda installation the image contains:

* pixiedust
* jupyter_contrib_nbextensions
* jupyter_nbextensions_configurator

The file inputPixiedustJupyterInstall.txt is used to answer to interactie jupyter installation script of pixiedust.
Unfortunately, there is no way to install pixiedust without interactions. The only way found up to now is to provide answers via a text file (inputPixiedustJupyterInstall.txt)

The installation script of pixiedust will create a kernel.json file with the following content:
```json
{
 "argv": [
  "python",
  "-m",
  "ipykernel",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python with Pixiedust (Spark 2.2)",
 "language": "python",
 "env": {
  "PIXIEDUST_HOME": "/root/pixiedust",
  "SCALA_HOME": "/root/pixiedust/bin/scala/scala-2.11.8",
  "SPARK_HOME": "/opt/spark",
  "PYTHONPATH": "/opt/spark/python/:/opt/spark/python/lib/py4j-0.10.4-src.zip",
  "PYTHONSTARTUP": "/opt/spark/python/pyspark/shell.py",
  "PYSPARK_SUBMIT_ARGS": "--jars /root/pixiedust/bin/cloudant-spark-v2.0.0-185.jar --driver-class-path /root/pixiedust/data/libs/* --master local[10] pyspark-shell",
  "SPARK_DRIVER_MEMORY": "10G",
  "SPARK_LOCAL_IP": "127.0.0.1"
 }
}
```
Fortunately, it rely on environment variables, unfortunately, the kernel.json overwrites environment variables that would have been set previously in the container.
To allow docker service to manage spark parameters, we remove the population of the folowing variables:
* PYSPARK_SUBMIT_ARGS
* SPARK_DRIVER_MEMORY
* SPARK_LOCAL_IP

so they can be set by docker service definition

Added value of Pixie dust:

* interactive visualization with different renderer (matplotlib, seaborn, bokeh)
* spark job monitor that let you visualize the spark tasks progress and details
* debbuger (https://medium.com/ibm-watson-data-lab/the-visual-python-debugger-for-jupyter-notebooks-youve-always-wanted-761713babc62)
