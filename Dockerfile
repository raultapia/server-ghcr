FROM ubuntu:latest

RUN apt update
RUN apt install -y systemd
RUN apt install -y systemd-sysv
RUN apt install -y cron
RUN apt install -y nano

ENV SHUTDOWN_TIME="0 2"

RUN echo '#!/bin/bash' > /log_shutdown.sh && \
    echo 'LOG_FILE="/var/log/shutdown.log"' >> /log_shutdown.sh && \
    echo 'echo "Current time: $(date)" >> $LOG_FILE' >> /log_shutdown.sh && \
    echo 'NEXT_SCHEDULE=$(grep "/sbin/shutdown now" /etc/cron.d/mycron | awk "{print \$1, \$2, \$3, \$4, \$5}")' >> /log_shutdown.sh && \
    echo 'echo "Next shutdown scheduled (cron) at: $NEXT_SCHEDULE" >> $LOG_FILE' >> /log_shutdown.sh && \
    echo 'if [ $(stat -c%s "$LOG_FILE") -gt 1073741824 ]; then > $LOG_FILE; fi' >> /log_shutdown.sh && \
    chmod +x /log_shutdown.sh

CMD ["/bin/bash", "-c", "\
    echo -e \"${SHUTDOWN_TIME} * * * /sbin/shutdown now\" > /etc/cron.d/mycron && \
    echo -e \"0 * * * * /log_shutdown.sh\" >> /etc/cron.d/mycron && \
    chmod 644 /etc/cron.d/mycron && \
    crontab /etc/cron.d/mycron && \
    cron -f"]