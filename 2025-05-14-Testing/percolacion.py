import numpy as np
import matplotlib.pyplot as plt
import time
from tqdm import tqdm

class PercolationSimulation:
    def __init__(self, L):
        """
        Inicializa la simulación de percolación para una matriz LxL
        
        Args:
            L (int): Tamaño de la matriz (LxL)
        """
        self.L = L
        self.grid = np.zeros((L, L), dtype=int)  # 0: cerrado, 1: abierto
        self.clusters = None
        self.largest_cluster_size = 0
        self.percolates = False
    
    def reset(self):
        """Reinicia la simulación con una matriz vacía"""
        self.grid = np.zeros((L, L), dtype=int)
        self.clusters = None
        self.largest_cluster_size = 0
        self.percolates = False
    
    def generate_random_grid(self, p):
        """
        Genera una matriz aleatoria donde cada celda tiene probabilidad p de estar abierta
        
        Args:
            p (float): Probabilidad de que un sitio esté abierto (0 <= p <= 1)
        """
        self.reset()
        self.grid = np.random.random((self.L, self.L)) < p
        self.grid = self.grid.astype(int)
        
    def identify_clusters(self):
        """
        Identifica clusters de sitios conectados usando el algoritmo de Hoshen-Kopelman
        
        Returns:
            numpy.ndarray: Matriz con etiquetas de clusters
        """
        L = self.L
        grid = self.grid
        
        # Inicializar matrices de etiquetas y de equivalencias
        labels = np.zeros((L, L), dtype=int)
        next_label = 1
        equivalences = {}
        
        # Primera pasada: asignar etiquetas y registrar equivalencias
        for i in range(L):
            for j in range(L):
                if grid[i, j] == 1:  # Si el sitio está abierto
                    # Verificar vecinos (arriba y a la izquierda)
                    neighbors = []
                    
                    if i > 0 and grid[i-1, j] == 1:  # Vecino arriba
                        neighbors.append(labels[i-1, j])
                    
                    if j > 0 and grid[i, j-1] == 1:  # Vecino izquierda
                        neighbors.append(labels[i, j-1])
                    
                    if not neighbors:  # No hay vecinos, nueva etiqueta
                        labels[i, j] = next_label
                        equivalences[next_label] = [next_label]
                        next_label += 1
                    else:
                        # Usar la etiqueta más pequeña
                        min_label = min([n for n in neighbors if n > 0])
                        labels[i, j] = min_label
                        
                        # Registrar equivalencias
                        for n in neighbors:
                            if n > 0:  # Solo considerar etiquetas válidas
                                if min_label not in equivalences[n]:
                                    equivalences[n].append(min_label)
                                if n not in equivalences[min_label]:
                                    equivalences[min_label].append(n)
        
        # Resolver equivalencias (encontrar la etiqueta raíz para cada etiqueta)
        def find_root(label, equivalences):
            if label == min(equivalences[label]):
                return label
            else:
                return find_root(min(equivalences[label]), equivalences)
        
        # Crear mapa de etiquetas a etiquetas raíz
        label_map = {}
        for label in equivalences:
            label_map[label] = find_root(label, equivalences)
        
        # Segunda pasada: actualizar etiquetas
        clusters = np.zeros((L, L), dtype=int)
        for i in range(L):
            for j in range(L):
                if labels[i, j] > 0:
                    clusters[i, j] = label_map[labels[i, j]]
        
        self.clusters = clusters
        return clusters
    
    def check_percolation(self):
        """
        Verifica si existe un cluster percolante (de arriba a abajo)
        
        Returns:
            bool: True si hay percolación, False en caso contrario
        """
        if self.clusters is None:
            self.identify_clusters()
        
        # Obtener los clusters en la primera y última fila
        top_clusters = set(self.clusters[0, :])
        bottom_clusters = set(self.clusters[-1, :])
        
        # Eliminar el cluster "0" (sitios cerrados)
        if 0 in top_clusters:
            top_clusters.remove(0)
        if 0 in bottom_clusters:
            bottom_clusters.remove(0)
        
        # Verificar si hay un cluster que aparece tanto arriba como abajo
        percolating_clusters = top_clusters.intersection(bottom_clusters)
        
        self.percolates = len(percolating_clusters) > 0
        return self.percolates
    
    def get_largest_cluster_size(self):
        """
        Calcula el tamaño del cluster más grande
        
        Returns:
            int: Tamaño del cluster más grande
        """
        if self.clusters is None:
            self.identify_clusters()
        
        unique, counts = np.unique(self.clusters, return_counts=True)
        if len(unique) > 1:  # Si hay al menos un cluster (además de los sitios cerrados)
            cluster_sizes = {u: c for u, c in zip(unique, counts)}
            if 0 in cluster_sizes:  # Eliminar el cluster "0" (sitios cerrados)
                del cluster_sizes[0]
            
            if cluster_sizes:  # Si hay algún cluster después de eliminar el 0
                self.largest_cluster_size = max(cluster_sizes.values())
                return self.largest_cluster_size
        
        self.largest_cluster_size = 0
        return 0
    
    def find_percolating_cluster_size(self):
        """
        Encuentra el tamaño del cluster percolante, si existe
        
        Returns:
            int: Tamaño del cluster percolante, 0 si no existe
        """
        if self.clusters is None:
            self.identify_clusters()
        
        if not self.check_percolation():
            return 0
        
        # Obtener los clusters en la primera y última fila
        top_clusters = set(self.clusters[0, :])
        bottom_clusters = set(self.clusters[-1, :])
        
        # Eliminar el cluster "0" (sitios cerrados)
        if 0 in top_clusters:
            top_clusters.remove(0)
        if 0 in bottom_clusters:
            bottom_clusters.remove(0)
        
        # Encontrar clusters percolantes
        percolating_clusters = list(top_clusters.intersection(bottom_clusters))
        
        if not percolating_clusters:
            return 0
        
        # Contar el tamaño del primer cluster percolante encontrado
        perc_cluster = percolating_clusters[0]
        return np.sum(self.clusters == perc_cluster)
    
    def plot_grid(self, save_path=None):
        """
        Visualiza la matriz de percolación con clusters coloreados
        
        Args:
            save_path (str, optional): Ruta para guardar la imagen. Si es None, muestra la imagen.
        """
        if self.clusters is None:
            self.identify_clusters()
        
        plt.figure(figsize=(8, 8))
        
        # Crear una matriz de colores para los clusters
        unique_clusters = np.unique(self.clusters)
        num_clusters = len(unique_clusters)
        
        # Crear un mapa de colores para cada cluster
        cmap = plt.cm.get_cmap('tab20', num_clusters)
        colored_grid = np.zeros((self.L, self.L, 3))
        
        for i in range(self.L):
            for j in range(self.L):
                if self.clusters[i, j] == 0:  # Sitio cerrado
                    colored_grid[i, j] = [0.9, 0.9, 0.9]  # Gris claro
                else:
                    # Asignar color basado en el índice del cluster
                    color_idx = np.where(unique_clusters == self.clusters[i, j])[0][0]
                    colored_grid[i, j] = cmap(color_idx)[:3]
        
        plt.imshow(colored_grid)
        plt.title(f"Percolación en malla {self.L}x{self.L}")
        plt.grid(False)
        
        if save_path:
            plt.savefig(save_path)
            plt.close()
        else:
            plt.show()

def estimate_pc(L, p_values, num_simulations=30):
    """
    Estima la probabilidad crítica pc para un tamaño de sistema L
    
    Args:
        L (int): Tamaño del sistema
        p_values (list): Lista de valores de probabilidad a probar
        num_simulations (int): Número de simulaciones para cada valor de p
        
    Returns:
        tuple: (pc, percolation_probability), donde pc es el valor estimado de la 
               probabilidad crítica y percolation_probability es la probabilidad de 
               percolación para cada valor de p
    """
    sim = PercolationSimulation(L)
    percolation_probability = []
    
    for p in tqdm(p_values, desc=f"Estimando pc para L={L}"):
        percolates_count = 0
        
        for _ in range(num_simulations):
            sim.generate_random_grid(p)
            if sim.check_percolation():
                percolates_count += 1
        
        prob = percolates_count / num_simulations
        percolation_probability.append(prob)
    
    # Estimar pc usando interpolación lineal
    # Buscamos dónde la probabilidad de percolación es 0.5
    pc_idx = np.argmin(np.abs(np.array(percolation_probability) - 0.5))
    pc = p_values[pc_idx]
    
    return pc, percolation_probability

def calculate_mean_cluster_size(L, p, num_simulations=30):
    """
    Calcula el tamaño medio del cluster percolante para un tamaño de sistema L y probabilidad p
    
    Args:
        L (int): Tamaño del sistema
        p (float): Probabilidad de sitio abierto
        num_simulations (int): Número de simulaciones
        
    Returns:
        tuple: (mean_size, std_size), donde mean_size es el tamaño medio del cluster percolante
               y std_size es la desviación estándar
    """
    sim = PercolationSimulation(L)
    cluster_sizes = []
    
    for _ in range(num_simulations):
        sim.generate_random_grid(p)
        sim.identify_clusters()
        
        if sim.check_percolation():
            size = sim.find_percolating_cluster_size()
            # Normalizar por el tamaño del sistema
            cluster_sizes.append(size / (L * L))
    
    if not cluster_sizes:
        return 0, 0
    
    return np.mean(cluster_sizes), np.std(cluster_sizes)

def run_percolation_analysis(L_values, p_values, num_simulations=30):
    """
    Ejecuta el análisis completo de percolación para diferentes tamaños de sistema
    
    Args:
        L_values (list): Lista de tamaños de sistema a analizar
        p_values (list): Lista de valores de probabilidad a probar
        num_simulations (int): Número de simulaciones para cada combinación de L y p
        
    Returns:
        dict: Resultados del análisis
    """
    results = {
        'L_values': L_values,
        'p_values': p_values,
        'pc_estimates': [],
        'percolation_probabilities': [],
        'cluster_sizes': {},
        'execution_time': 0
    }
    
    start_time = time.time()
    
    # Para cada tamaño de sistema
    for L in L_values:
        print(f"\nAnalizando sistema de tamaño L = {L}")
        
        # Estimar pc
        pc, percolation_prob = estimate_pc(L, p_values, num_simulations)
        results['pc_estimates'].append(pc)
        results['percolation_probabilities'].append(percolation_prob)
        
        print(f"Probabilidad crítica estimada para L={L}: pc ≈ {pc:.4f}")
        
        # Calcular tamaños de cluster para diferentes valores de p
        cluster_sizes = []
        for p in tqdm(p_values, desc=f"Calculando tamaños de cluster para L={L}"):
            mean_size, std_size = calculate_mean_cluster_size(L, p, num_simulations)
            cluster_sizes.append((mean_size, std_size))
        
        results['cluster_sizes'][L] = cluster_sizes
    
    results['execution_time'] = time.time() - start_time
    
    return results

def plot_percolation_probability(results, save_path=None):
    """
    Grafica la probabilidad de percolación vs p para diferentes tamaños de sistema
    
    Args:
        results (dict): Resultados del análisis de percolación
        save_path (str, optional): Ruta para guardar la imagen
    """
    plt.figure(figsize=(10, 6))
    
    L_values = results['L_values']
    p_values = results['p_values']
    
    for i, L in enumerate(L_values):
        percolation_prob = results['percolation_probabilities'][i]
        plt.plot(p_values, percolation_prob, 'o-', label=f'L = {L}')
    
    plt.axhline(y=0.5, color='r', linestyle='--', alpha=0.7, label='P = 0.5')
    plt.xlabel('Probabilidad p')
    plt.ylabel('Probabilidad de percolación')
    plt.title('Probabilidad de percolación vs p para diferentes tamaños de sistema')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    if save_path:
        plt.savefig(save_path)
        plt.close()
    else:
        plt.show()

def plot_pc_vs_L(results, save_path=None):
    """
    Grafica la probabilidad crítica pc vs 1/L
    
    Args:
        results (dict): Resultados del análisis de percolación
        save_path (str, optional): Ruta para guardar la imagen
    """
    plt.figure(figsize=(10, 6))
    
    L_values = np.array(results['L_values'])
    pc_estimates = np.array(results['pc_estimates'])
    
    # Graficar pc vs 1/L
    inv_L = 1 / L_values
    plt.plot(inv_L, pc_estimates, 'o-')
    
    # Ajuste lineal para estimar pc(∞)
    coef = np.polyfit(inv_L, pc_estimates, 1)
    poly = np.poly1d(coef)
    plt.plot(inv_L, poly(inv_L), 'r--', label=f'Ajuste: pc(∞) ≈ {poly(0):.4f}')
    
    plt.xlabel('1/L')
    plt.ylabel('Probabilidad crítica pc')
    plt.title('Extrapolación de pc para L → ∞')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    if save_path:
        plt.savefig(save_path)
        plt.close()
    else:
        plt.show()

def plot_cluster_size(results, save_path=None):
    """
    Grafica el tamaño medio del cluster percolante vs p para diferentes tamaños de sistema
    
    Args:
        results (dict): Resultados del análisis de percolación
        save_path (str, optional): Ruta para guardar la imagen
    """
    plt.figure(figsize=(10, 6))
    
    L_values = results['L_values']
    p_values = results['p_values']
    
    for L in L_values:
        cluster_sizes = results['cluster_sizes'][L]
        mean_sizes = [size[0] for size in cluster_sizes]
        plt.plot(p_values, mean_sizes, 'o-', label=f'L = {L}')
    
    plt.xlabel('Probabilidad p')
    plt.ylabel('Tamaño medio del cluster percolante (normalizado)')
    plt.title('Tamaño del cluster percolante vs p para diferentes tamaños de sistema')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    if save_path:
        plt.savefig(save_path)
        plt.close()
    else:
        plt.show()

def generate_report(results, filename="percolation_report.txt"):
    """
    Genera un reporte con los resultados del análisis de percolación
    
    Args:
        results (dict): Resultados del análisis de percolación
        filename (str): Nombre del archivo para guardar el reporte
    """
    with open(filename, 'w') as f:
        f.write("REPORTE DE ANÁLISIS DE PERCOLACIÓN\n")
        f.write("=================================\n\n")
        
        f.write(f"Tiempo de ejecución: {results['execution_time']:.2f} segundos\n\n")
        
        f.write("Estimación de probabilidades críticas:\n")
        f.write("------------------------------------\n")
        for i, L in enumerate(results['L_values']):
            f.write(f"L = {L:3d}: pc ≈ {results['pc_estimates'][i]:.6f}\n")
        
        # Estimación de pc(∞) mediante ajuste lineal
        L_values = np.array(results['L_values'])
        pc_estimates = np.array(results['pc_estimates'])
        inv_L = 1 / L_values
        coef = np.polyfit(inv_L, pc_estimates, 1)
        pc_inf = coef[1]  # Término independiente del ajuste
        
        f.write(f"\nExtrapolación para L → ∞: pc(∞) ≈ {pc_inf:.6f}\n")
        f.write(f"Valor teórico esperado: pc(∞) = 0.59275\n")
        f.write(f"Error relativo: {abs(pc_inf - 0.59275) / 0.59275 * 100:.4f}%\n\n")
        
        f.write("Tamaño medio del cluster percolante para valores seleccionados de p:\n")
        f.write("------------------------------------------------------------\n")
        
        # Seleccionar algunos valores de p para mostrar en el reporte
        selected_indices = [
            np.argmin(np.abs(np.array(results['p_values']) - 0.5)),
            np.argmin(np.abs(np.array(results['p_values']) - 0.59)),
            np.argmin(np.abs(np.array(results['p_values']) - 0.7))
        ]
        
        for idx in selected_indices:
            p = results['p_values'][idx]
            f.write(f"\np = {p:.4f}:\n")
            
            for L in results['L_values']:
                mean_size, std_size = results['cluster_sizes'][L][idx]
                f.write(f"  L = {L:3d}: Tamaño medio = {mean_size:.6f} ± {std_size:.6f} (normalizado)\n")
        
        f.write("\nObservaciones:\n")
        f.write("-------------\n")
        f.write("1. La probabilidad crítica parece converger al valor teórico esperado (0.59275) a medida que L aumenta.\n")
        f.write("2. Para p < pc, la probabilidad de percolación tiende a 0 cuando L aumenta.\n")
        f.write("3. Para p > pc, la probabilidad de percolación tiende a 1 cuando L aumenta.\n")
        f.write("4. El tamaño del cluster percolante (normalizado) aumenta con p y con L.\n")

def main():
    """Función principal para ejecutar el programa"""
    # Parámetros de simulación
    L_values = [32, 64, 128, 256]  # Tamaños de sistema a analizar
    p_values = np.linspace(0.55, 0.65, 11)  # Valores de p a probar
    num_simulations = 30  # Número de simulaciones para cada combinación de L y p
    
    # Ejecutar análisis
    results = run_percolation_analysis(L_values, p_values, num_simulations)
    
    # Generar gráficas
    plot_percolation_probability(results, "percolation_probability.png")
    plot_pc_vs_L(results, "pc_vs_L.png")
    plot_cluster_size(results, "cluster_size.png")
    
    # Generar reporte
    generate_report(results, "percolation_report.txt")
    
    print("\nAnálisis completado. Se han generado gráficas y un reporte con los resultados.")
    
    # Ejemplo de visualización
    print("\nGenerando ejemplo visual de percolación...")
    sim = PercolationSimulation(32)
    
    # Ejemplo sin percolación
    sim.generate_random_grid(0.5)
    sim.identify_clusters()
    sim.check_percolation()
    sim.plot_grid("percolation_example_p05.png")
    print(f"Percolación con p=0.5: {'Sí' if sim.percolates else 'No'}")
    
    # Ejemplo con percolación
    sim.generate_random_grid(0.6)
    sim.identify_clusters()
    sim.check_percolation()
    sim.plot_grid("percolation_example_p06.png")
    print(f"Percolación con p=0.6: {'Sí' if sim.percolates else 'No'}")

if __name__ == "__main__":
    main()