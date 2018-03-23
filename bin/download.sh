DOWNLOAD_FILE=spark-2.3.0-bin-hadoop2.7
DOWNLOAD_LINK="http://apache.spinellicreations.com/spark/spark-2.3.0/${DOWNLOAD_FILE}.tgz"

mkdir -p resources/dist
cd resources/dist
wget ${DOWNLOAD_LINK}
tar xvzf "${DOWNLOAD_FILE}.tgz"
