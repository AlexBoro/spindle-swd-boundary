# NEURON 7.8.2 build for the vendored Dervinis & Crunelli corticothalamic model.
# Pinned deliberately: the vendored .mod files do not compile on NEURON 8.2+
# (see environment/README.md).
FROM python:3.8-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential bison flex libncurses5-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "neuron==7.8.2" numpy

WORKDIR /opt/model
COPY model/thalamocortical2/ /opt/model/

# Compile mechanisms at image-build time, never at run time.
RUN nrnivmodl . && test -x x86_64/special

COPY sim/ /opt/sim/
COPY analysis/ /opt/analysis/
ENV PYTHONPATH=/opt

ENTRYPOINT ["python", "/opt/sim/runner.py"]
