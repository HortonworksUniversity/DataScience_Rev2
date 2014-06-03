define kmeans `python kmeans.py` ship ('kmeans.py');

rmf kmeans_output;

news = load 'newsgroups.avro' using AvroStorage();
--describe news;

--Data filtering - only keep data for topics with >= 100 articles
one_topic_per_article = foreach news generate *, flatten(TOKENIZE(newsgroups, ',')) as topic;
news_by_topic = group one_topic_per_article by topic;
article_counts = foreach news_by_topic generate group as topic, COUNT(one_topic_per_article) as articleCount, one_topic_per_article as articles;
split article_counts into 
  keep if articleCount >= 100,
  discard if articleCount < 100;
news_by_major_topic = foreach keep generate topic, flatten(articles.(articleId, content)) as (articleId, content);

-- Data distribution and cleaning - group data by topic across multiple reducers
-- then trim newlines and tables from the message content 
grouped_content = group news_by_major_topic by topic parallel 10;
flattened_content = foreach grouped_content generate group as topic, flatten(news_by_major_topic.(articleId, content)) as (articleId, content);
cleaned_content = foreach flattened_content generate topic, articleId as articleId, REPLACE(REPLACE(REPLACE(content, '\\n', ' '), '\\r', ''), '\\t', ' ') as content;
filtered_content = filter cleaned_content by (TRIM(content) != '');

-- Processing - send the filtered, cleaned, grouped data to the 
-- external Python K-Means clustering algorithm, then sort the results 
-- and write the clusters to HDFS
