define freqdist `python freqdist.py` ship ('freqdist.py');

register 'elephant-bird-pig-4.4.jar';
register 'elephant-bird-hadoop-compat-4.4.jar';
register 'json-simple-1.1.jar';

commits = load 'commits.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') as (json:map[]);

messages = foreach commits generate json#'commit'#'message';

analyzed = stream messages through freqdist; 

structured_analysis = foreach analyzed generate (chararray) $0 as word:chararray, (int) $1 as count:int;

dump structured_analysis;
