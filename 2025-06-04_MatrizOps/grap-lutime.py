import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('lu_benchmark.tsv', sep='\t')
plt.figure(figsize=(10,5))
plt.errorbar(df['Threads'], df['Mean_WTime(s)'], yerr=df['Sigma_WTime'], label='Wall Time')
plt.errorbar(df['Threads'], df['Mean_CTime(s)'], yerr=df['Sigma_CTime'], label='CPU Time')
plt.xlabel('Número de Hilos')
plt.ylabel('Tiempo (s)')
plt.title('Time vs size')
plt.legend()
plt.grid(True)
plt.savefig('scaling_plot.png')
plt.show()