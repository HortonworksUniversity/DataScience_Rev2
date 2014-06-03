register 'udfs.py' using jython as udfs;

emails = load 'mbox7.avro' using AvroStorage();
--describe emails;

emailsBySender = group emails by udfs.getFromEmail(From) parallel 3;

senderWords = foreach emailsBySender generate group as fromEmail, udfs.getTop5Words(emails.(Content)) as top5Words;

dump senderWords;
