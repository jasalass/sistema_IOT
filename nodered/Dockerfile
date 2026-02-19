FROM nodered/node-red:latest

USER root

# Include dashboard nodes in the image so /ui is available out-of-the-box.
RUN npm install --unsafe-perm --no-update-notifier --no-fund \
    node-red-dashboard@3.6.5

USER node-red
