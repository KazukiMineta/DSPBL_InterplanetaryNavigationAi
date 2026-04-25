import numpy as np
import pandas as pd
import os
from tqdm import tqdm
from datetime import datetime, timedelta

import parameter as P

# ============================
# 入力：開始日・終了日
# ============================
start_dt = datetime.fromisoformat(P.TERM["start"])
end_dt   = datetime.fromisoformat(P.TERM["end"])

# J2000 epoch
J2000 = datetime(2000, 1, 1, 12, 0, 0)

# 日数リスト生成
delta_days = (end_dt - start_dt).days
days = np.arange(0, delta_days + 1)  # 1日刻み

# 経過秒数（J2000 からの秒）
t = np.array([(start_dt + timedelta(days=int(d)) - J2000).total_seconds() for d in days])

# ============================
# Constants
# ============================
mu_sun = P.SUN["mu"]
planets = P.PLANETS
satellites = P.MOONS

# ============================
# Kepler solver
# ============================
def kepler_E(M, e):
    E = M
    for _ in range(20):
        E = M + e*np.sin(E)
    return E

def kepler_to_r_2d(a, e, i, Om, om, M):
    E = kepler_E(M, e)
    x = a*(np.cos(E) - e)
    y = a*np.sqrt(1-e**2)*np.sin(E)

    theta = Om + om
    R = np.array([[np.cos(theta), -np.sin(theta)],
                  [np.sin(theta),  np.cos(theta)]])
    r2 = R @ np.array([x, y])
    return r2[0], r2[1]

# ============================
# Compute with progress bar
# ============================
rows = []

print("\n=== Calculating planetary orbits ===")
for name, (a,e,i,Om,om,M0) in tqdm(planets.items()):
    a = float(a)
    e = float(e)
    i  = np.deg2rad(i)
    Om = np.deg2rad(Om)
    om = np.deg2rad(om)
    M0 = np.deg2rad(M0)

    n = np.sqrt(mu_sun / a**3)

    for ti, day in zip(t, days):
        M = M0 + n * ti
        x, y = kepler_to_r_2d(a,e,i,Om,om,M)
        rows.append([name, day, x, y])

print("\n=== Calculating moons ===")
for sat, (parent, a,e,i,Om,om,M0) in tqdm(satellites.items()):
    a = float(a)
    e = float(e)
    i  = np.deg2rad(i)
    Om = np.deg2rad(Om)
    om = np.deg2rad(om)
    M0 = np.deg2rad(M0)

    # parent planet
    pa,pe,pi,pOm,pom,pM0 = planets[parent]
    pa = float(pa)
    pe = float(pe)
    pi  = np.deg2rad(pi)
    pOm = np.deg2rad(pOm)
    pom = np.deg2rad(pom)
    pM0 = np.deg2rad(pM0)
    pn = np.sqrt(mu_sun / pa**3)

    # moon GM（簡易モデル）
    mu_moon = 4.282837e4

    for ti, day in zip(t, days):
        # planet position
        Mp = pM0 + pn * ti
        px, py = kepler_to_r_2d(pa,pe,pi,pOm,pom,Mp)

        # moon position
        n = np.sqrt(mu_moon / a**3)
        Ms = M0 + n * ti
        sx, sy = kepler_to_r_2d(a,e,i,Om,om,Ms)

        rows.append([sat, day, px + sx, py + sy])

# ============================
# Save CSV
# ============================
df = pd.DataFrame(rows, columns=["body","day","x","y"])

script_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(script_dir, "solar_system_with_moons_2d.csv")
df.to_csv(csv_path, index=False)

print(f"\nSaved CSV at: {csv_path}\n")
