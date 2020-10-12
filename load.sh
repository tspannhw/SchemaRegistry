clear

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ Starting to create all the demo   ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo " *** Thanks Paul Vidal *** "
echo " *** Thanks Andre *** "
echo " *** Thanks Dan ***"
echo ""
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
echo "⏱  $(date +%H%Mhrs)"
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
echo ""
echo ""

yum -y install git curl wget

# Andre's script 
cd /tmp/resources
./reset-to-lab.sh 12

# Created for edge2ai

cd /opt/demo

git clone https://github.com/tspannhw/SchemaRegistry
chmod -R 777 /opt/demo/FlinkSQLDemo

# Hadoop HDFS

HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /user/admin
HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /user/root
HADOOP_USER_NAME=hdfs hdfs dfs -chown root:root /user/root
HADOOP_USER_NAME=hdfs hdfs dfs -chown admin:admin /user/admin
HADOOP_USER_NAME=hdfs hdfs dfs -chmod -R 777 /user
HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /user/kafka
HADOOP_USER_NAME=hdfs hdfs dfs -chmod -R 777 /

cd /opt/demo/SchemaRegistry

echo ""
echo ""
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
echo " Building Schemas"
echo ""
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
echo ""
echo ""

#
# Get Schema Registry URL
curl -X GET "http://edge2ai-1.dim.local:8585/api/v1/admin/schemas/registryInfo" -H "accept: application/json"

echo ""
echo ""

# Load Schemas into Schema Registry
# https://registry-project.readthedocs.io/en/latest/schema-registry.html#api-examples
# http://edge2ai-1.dim.local:7788/swagger

for f in /opt/demo/SchemaRegistry/schemas/*.avsc
do 

echo "Uploading Schema File $f"
schemaname="`echo $f | awk -F'[/_.]' '{print $(NF-1)}'`"
echo "Schema [$schemaname]"
echo ""

curl -X POST "http://edge2ai-1.dim.local:7788/api/v1/schemaregistry/schemas" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"type\": \"avro\", \"schemaGroup\": \"Kafka\", \"name\": \"$schemaname\", \"description\": \"schemaname\", \"compatibility\": \"BOTH\", \"validationLevel\": \"LATEST\"}"

echo ""

# Upload body

curl -X POST "http://edge2ai-1.dim.local:7788/api/v1/schemaregistry/schemas/$schemaname/versions/upload?branch=MASTER&disableCanonicalCheck=false" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "file=@/opt/demo/ApacheConAtHome2020/schemas/$schemaname.avsc;type=application/json" -F "description=schemaname"

echo "Added."
echo ""

done

echo ""
echo ""
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
echo ""
echo "Completed."
echo ""
echo "⏱  $(date +%H%Mhrs)"
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
