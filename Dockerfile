# build as:
# docker build  --tag abarth/divand-bluecloud:$(date --utc +%Y-%m-%dT%H%M)  --tag abarth/divand-bluecloud:latest .

FROM julia:1.5

MAINTAINER Alexander Barth <a.barth@ulg.ac.be>

EXPOSE 8888

USER root

RUN apt-get update
RUN apt-get install -y libnetcdf-dev netcdf-bin
RUN apt-get install -y unzip
RUN apt-get install -y ca-certificates curl
###RUN apt-get install -y git
RUN apt-get install -y python3-matplotlib
RUN apt-get install -y gcc
RUN apt-get install -y python3-pip

ENV PYTHON /usr/bin/python3


RUN julia --eval 'using Pkg; pkg"add PyPlot Interpolations MAT"'
RUN julia --eval 'using Pkg; pkg"add JSON SpecialFunctions Roots"'
RUN julia --eval 'using Pkg; pkg"add Gumbo AbstractTrees Glob NCDatasets Knet CSV"'
RUN julia --eval 'using Pkg; pkg"add DataStructures Compat Mustache"'
RUN julia --eval 'using Pkg; pkg"add StableRNGs Missings NBInclude HTTP"'

RUN julia --eval 'using Pkg; pkg"add PhysOcean"'
#RUN julia --eval 'using Pkg; pkg"dev PhysOcean"'
RUN julia --eval 'using Pkg; pkg"add https://github.com/gher-ulg/OceanPlot.jl#master"'
RUN julia --eval 'using Pkg; pkg"add https://github.com/gher-ulg/DIVAnd.jl#master"'



# Pre-compiled image with PackageCompiler
RUN julia --eval 'using Pkg; pkg"add PackageCompiler"'
ADD DIVAnd_precompile_script.jl .
ADD make_sysimg.sh .
RUN ./make_sysimg.sh
RUN mkdir -p /opt/julia-DIVAnd
RUN mv DIVAnd_precompile_script.jl make_sysimg.sh  DIVAnd_trace_compile.jl  /opt/julia-DIVAnd
RUN rm -f test.xml Water_body_Salinity.3Danl.nc Water_body_Salinity.4Danl.cdi_import_errors_test.csv Water_body_Salinity.4Danl.nc Water_body_Salinity2.4Danl.nc



RUN pip3 install requests


WORKDIR /sortapp
ADD setup.py .
ADD src src
ADD README.md .
ADD LICENSE.md .


RUN python3 setup.py install

#ENTRYPOINT ["top", "-b"]
#ENTRYPOINT ["/usr/local/julia/bin/julia","--sysimage=/opt/julia-DIVAnd/sysimg_DIVAnd.so"]
