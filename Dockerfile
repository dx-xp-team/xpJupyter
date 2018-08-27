FROM continuumio/anaconda3

RUN apt-get -y update
RUN apt-get -y install default-jre
RUN apt-get -y install python-pip
RUN pip install --upgrade pip
RUN pip install pixiedust jupyter_contrib_nbextensions jupyter_nbextensions_configurator tensorflow
RUN pip install --upgrade html5lib

# Install Spark for Driver
RUN curl -s http://apache.claz.org/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz  | tar xz -C /opt
RUN ln -s /opt/spark-2.3.1-bin-hadoop2.7 /opt/spark

# Install Pixiedust and remove some hardcoded parameters so they can be set in Docker compose file
ADD inputPixiedustJupyterInstall.txt /tmp/
RUN jupyter pixiedust install < /tmp/inputPixiedustJupyterInstall.txt
RUN sed -i '/PYSPARK_SUBMIT_ARGS/d'  /root/.local/share/jupyter/kernels/pythonwithpixiedustspark23/kernel.json
RUN sed -i '/SPARK_DRIVER_MEMORY/d' /root/.local/share/jupyter/kernels/pythonwithpixiedustspark23/kernel.json
RUN sed -i '/SPARK_LOCAL_IP/d' /root/.local/share/jupyter/kernels/pythonwithpixiedustspark23/kernel.json
RUN sed -i -e 's/pyspark\/shell.py\",/pyspark\/shell.py\"/g' /root/.local/share/jupyter/kernels/pythonwithpixiedustspark23/kernel.json

# Install Jupyter nbextensions
RUN jupyter contrib nbextension install
RUN jupyter nbextensions_configurator enable

# Extend Jupyter dispaly width from 50% (default) to 99%
ADD custom.css /root/.jupyter/custom/

# Configure Spark
WORKDIR /opt/spark
RUN cp /opt/spark/conf/spark-defaults.conf.template /opt/spark/conf/spark-defaults.conf
RUN echo 'spark.driver.extraJavaOptions=-Dhttp.proxyHost=http://proxy.lbs.alcatel-lucent.com -Dhttp.proxyPort=8000 -Dhttps.proxyHost=http://proxy.lbs.alcatel-lucent.com -Dhttps.proxyPort=8000' >> /opt/spark/conf/spark-defaults.conf
RUN echo 'spark.ui.reverseProxy true' >> /opt/spark/conf/spark-defaults.conf

# Add support of AWS S3 connectivity
COPY aws-java-sdk-1.7.4.jar hadoop-aws-2.7.3.jar /opt/spark/jars/
RUN echo 'spark.hadoop.fs.s3a.proxy.host=proxy.lbs.alcatel-lucent.com' >> /opt/spark/conf/spark-defaults.conf
RUN echo 'spark.hadoop.fs.s3a.proxy.port=8000' >> /opt/spark/conf/spark-defaults.conf

# Jupyter config
COPY jupyter_notebook_config.json /root/.jupyter/
