# PublishTimezoneJSON.sh
#----------------------------------------------------------------------------------------------------------------
# 	Publishes an MQTT message that contains TimezoneJSON which Particle MPUs can use to configure local time.
#----------------------------------------------------------------------------------------------------------------
# Requirements:
#	The script uses the Linux host's timezone (obtained from /etc/timezone) and executes "mosquitto_pub" to 
#		publish the JSON. Script modifications will be required if these resources are not available.
#	The script calls mktime() to generate the dST transition times in epoch/unix format. Some Linux 
#		distributions (such as Debian) do not support this unless gawk (Gnome AWK) is installed or
#		script changes are made.  Sample instructions: https://howtoinstall.co/en/debian/stretch/gawk
# Linux Usage:
#	At a minimum, this AWK script should be run via cron on each January1 @ 00:00 (CronTab: 0 0 1 1 *) to 
#       	publish the theTimezoneJSON for the new year. The JSON is published with the -r (retain) option,
#	 	so the MQTT brokershould send it to any clients who subscribe during the year.
#	Running the script more often based on time or events (like a MQTT broker restart) would do no harm.
# TimezoneJSON includes:
#	<zone>  	a numeric (float) representation of the "standard" TZ offset (-12.0 to +12.0) 
#	<dstOffset> 	a numeric (float) DST offset from the "standard" time in hours
#	<isDST0>, <isDST1>, and <isdst2>  an (int) where the value 0 = standard time and 1 = DST
#	<trans0>, <trans1> are (time_t) epoch/UNIX times when DST transitions occur
# Particle Usage: 
#	Time.zone(<zone>);
#	Time.setDSTOffset(<dstOffset>);
#	Time.beginDST(); and Time.endDST() based on the isDST_ values
#		isDST0 should be used when (Time.now() !> trans0)
#		isDST1 should be used when (Time.now() > trans0) and (Time.now() !> trans1)
#		isDST2 should be used when (Time.now() > trans1)
#--------------------------------------------------------------------------------------------------------- SCRIPT
#----------------------------------------------------------------------------------------------------------------

#! /bin/bash
zdump -v $(cat /etc/timezone)  -c $(date '+%Y'),$(date -d '+1 year' '+%Y') | awk -F'[:= ]+' -v  y=$(date '+%Y') ' 
    { dy=$2; MTH=toupper($3); day=$4; hr=$5; min=$6; sec=$7; yr= $8; dst=$19;off=$21;}
    (yr==y) { count++;
	if (soff == "" && dst == 0) { soff = off/3600; 
	} else if (doff == "" && dst == 1) { doff = off/3600 - soff; 
	}
	if (count == 1) { dst0 = dst;
		mo= 1 + (index("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",MTH)-1)/3;
		tran0 = mktime(sprintf("%d %d %d %d %d %d", yr, mo, day, hr, min, sec)) + off;
	} else if (count == 3) { dst1 = dst;
		mo= 1 + (index("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",MTH)-1)/3;
		tran1 = mktime(sprintf("%d %d %d %d %d %d", yr, mo, day, hr, min, sec)) + off;
	} else if (count == 4) { dst2 = dst;
		buffer = sprintf("{\\\"zone\\\":%0.2f,\\\"DSTOffset\\\":%0.2f,\\\"isDST0\\\":%d,\\\"trans0\\\":%d,\\\"isDST1\\\":%d,\\\"trans1\\\":%d,\\\"isDST2\\\":%d}", soff, doff, dst0, tran0, dst1, tran1, dst2);
		system("mosquitto_pub -t time/zone -r -m " buffer);
		print buffer;   # <- optional
	}
}'