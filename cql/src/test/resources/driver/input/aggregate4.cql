set "operator.kafka.brokers"="192.168.0.2:9092";

create input stream S 
(id int ,name String,type int)
	 SERDE SimpleSerDe
		 PROPERTIES ("serde.simpleserde.separator" = ",")
	 SOURCE 'com.huawei.streaming.operator.inputstream.KafkaSourceOp'
		 PROPERTIES ("operator.kafka.groupid" = "gidkpi_1_1","operator.kafka.topic"="agg_4_1",
						"operator.kafka.zookeepers"="localhost:2181,192.168.0.2:2181",
						"operator.kafka.zksessiontimeout"="20000","operator.kafka.zksynctime"="20000",
							"operator.kafka.messageserializerclass"="kafka.serializer.StringEncoder");
							
	create output stream rs 
		(id string,name string,type int,cc int)
	 SERDE SimpleSerDe
		 PROPERTIES ("serde.simpleserde.separator" = ",")
	 SINK 'com.huawei.streaming.operator.outputstream.KafkaFunctionOp'
		 PROPERTIES ("operator.kafka.topic"="agg_4_2","operator.kafka.zksessiontimeout"="20000",	"operator.kafka.zookeepers"="192.168.0.2:2181",
						"operator.kafka.zksynctime"="20000","operator.kafka.messageserializerclass"="kafka.serializer.StringEncoder");
	-- 聚合查询测试，having中的列并没有出现在select的子句中
	insert into stream rs select *,count(id) from S[range 20 seconds batch] where id > 5 group by s.type having sum(id)>10;	
	explain application simple;