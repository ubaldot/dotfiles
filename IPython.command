source ~/.zshrc
conda activate myenv
mvim -c "call term_start('ipython',{'term_name': 'IPYTHON'})" -c "wincmd L"
