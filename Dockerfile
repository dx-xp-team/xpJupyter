FROM continuumio/anaconda3:5.2.0

RUN apt-get -y update
RUN apt-get -y install default-jre
RUN apt-get -y install python-pip libcr-dev mpich mpich-doc
RUN pip install --upgrade pip
RUN pip install pixiedust jupyter_contrib_nbextensions jupyter_nbextensions_configurator tensorflow horovod mlflow
RUN pip install --upgrade html5lib

# Install Jupyter nbextensions
RUN jupyter contrib nbextension install
RUN jupyter nbextensions_configurator enable

# Extend Jupyter dispaly width from 50% (default) to 99%
ADD custom.css /root/.jupyter/custom/

# Jupyter config
COPY jupyter_notebook_config.json /root/.jupyter/
