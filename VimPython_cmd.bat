@echo off
call C:\Users\yt75534\Miniconda3\condabin\activate.bat C:\Users\yt75534\Miniconda3\envs\myenv
gvim -c "vert botright call term_start('C:\\Users\\yt75534\\Miniconda3\\condabin\\conda.bat activate myenv && echo Conda env:%CONDA_DEFAULT_ENV% && ipython --profile=autoreload_profile', {'term_name': 'IPYTHON'})"






 
