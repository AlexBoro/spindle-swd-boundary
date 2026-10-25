import os, shutil, pandas as pd, numpy as np, matplotlib as mpl, matplotlib.pyplot as plt
from scipy import stats
apply_figure_style(sizes=(8, 7, 6))
R = 'spindle-swd-boundary'
m = pd.read_csv('d1/fig3_paired.csv'); rc = pd.read_csv('d1/recall_paired.csv')
S = sorted(m.seed.unique())
old = pd.read_csv(f'{R}/sweeps/wei2018_fig3/per_run.csv')
t0 = pd.read_csv(f'{R}/sweeps/wei2018_stage1/stage1_trials.csv'); t0 = t0[(t0.protocol == 'stage1_curve') & (t0.wset == 'n3') & t0.seed.isin(S)]
n3_fresh = t0.assign(s=(t0.sm >= .8) * 100).groupby('seed').s.mean()
n3 = old[(old.condition == 'n3') & old.seed.isin(S)].set_index('seed')
PAPER = {'dw': {'n2': 35, 'n2n3': 53, 'n3': 65}, 'perf': {'n2': 30, 'n2n3': 49, 'n3': 64}}
C_OLD, C_NEW = '#9a9a9a', '#5b3a8c'
panels = [('dw', 'Forward weight change\nafter sleep (%)', 'dw_after_sleep', 'N2 Δw reaches the paper value'),
          ('perf', 'In-run recall after sleep\n(% trials SM ≥ 0.8)', 'perf_after_sleep', 'In-run recall rises'),
          ('fresh', 'Fresh-state recall\n(% trials SM ≥ 0.8)', None, 'Fresh-state recall rises less')]
fig, axs = plt.subplots(1, 3, figsize=(7.1, 2.6)); fig.subplots_adjust(wspace=0.6)
conds = ['n2', 'n2n3']; lab = {'n2': 'N2', 'n2n3': 'N2+N3', 'n3': 'N3\n(unchanged)'}
for ax, (key, ylab, col, title), L in zip(axs, panels, 'abc'):
    for i, c in enumerate(conds):
        if key == 'fresh':
            d = rc[rc.cond == c].sort_values('seed'); yo, yn = d.succ_old.values, d.succ_f1.values
        else:
            d = m[m.condition == c].sort_values('seed'); yo, yn = d[col + '_old'].values, d[col + '_f1'].values
        x0, x1 = i - 0.17, i + 0.17
        for a, b in zip(yo, yn): ax.plot([x0, x1], [a, b], color='0.75', lw=0.6, zorder=1)
        ax.scatter([x0] * len(yo), yo, s=14, color=C_OLD, zorder=2, label='N2 STDP halved (before)' if i == 0 else None)
        ax.scatter([x1] * len(yn), yn, s=14, color=C_NEW, zorder=2, label='N2 STDP full (D1)' if i == 0 else None)
        ax.hlines([yo.mean()], x0 - .1, x0 + .1, color=C_OLD, lw=1.6, zorder=3); ax.hlines([yn.mean()], x1 - .1, x1 + .1, color=C_NEW, lw=1.6, zorder=3)
        if key in PAPER: ax.hlines(PAPER[key][c], i - .32, i + .32, color='k', lw=0.9, ls=(0, (2, 1.5)), zorder=0, label='paper' if i == 0 else None)
    y3 = n3_fresh.values if key == 'fresh' else n3[col].values
    ax.scatter([2] * len(y3), y3, s=14, color=C_OLD, zorder=2); ax.hlines([y3.mean()], 1.9, 2.1, color=C_OLD, lw=1.6)
    if key in PAPER: ax.hlines(PAPER[key]['n3'], 1.68, 2.32, color='k', lw=0.9, ls=(0, (2, 1.5)), zorder=0)
    ax.set_xticks([0, 1, 2], [lab[c] for c in ['n2', 'n2n3', 'n3']]); ax.set_xlim(-0.5, 2.5); ax.set_ylabel(ylab)
    ax.set_title(title, loc='left', fontsize=7, pad=8); ax.margins(y=0.08); panel_letter(ax, L)
h, l = axs[0].get_legend_handles_labels()
fig.legend(h, l, frameon=False, loc='upper center', bbox_to_anchor=(0.5, -0.02), ncol=3, fontsize=7)
fig.savefig('wei2018_stage2_d1.png', dpi=300, bbox_inches='tight')
rows = []
for c in conds:
    a = m[m.condition == c]; q = rc[rc.cond == c]
    for met, x, y in [('dw forward after sleep (%)', a.dw_after_sleep_old, a.dw_after_sleep_f1),
                      ('in-run recall after sleep, SM>=0.8 (%)', a.perf_after_sleep_old, a.perf_after_sleep_f1),
                      ('fresh-state recall, SM>=0.8 (%)', q.succ_old, q.succ_f1),
                      ('fresh-state recall, exact ABCDE (%)', q.exact_old, q.exact_f1)]:
        rows.append(dict(cond=c, metric=met, before=x.mean(), d1=y.mean(), d1_sd=y.std(ddof=1), diff=(y.values - x.values).mean(),
                         p_paired=stats.ttest_rel(y, x).pvalue, n=len(x)))
T = pd.DataFrame(rows); print(T.round(3).to_string(index=False))
print('n3 ref seeds', S, 'dw', round(n3.dw_after_sleep.mean(), 2), 'inrun', n3.perf_after_sleep.mean(), 'fresh', round(n3_fresh.mean(), 2))
print(m[['condition', 'seed', 'dw_after_sleep_f1', 'perf_after_sleep_f1']].round(1).to_string(index=False))
print(rc[['cond', 'seed', 'succ_f1', 'succ_old']].round(1).to_string(index=False))
od = f'{R}/sweeps/wei2018_stage2/d1'; os.makedirs(od, exist_ok=True)
T.to_csv(f'{od}/d1_contrasts.csv', index=False)
for f in ['fig3_paired.csv', 'recall_paired.csv', 'prefix_checks.csv', 'stage1_trials_f1.csv']: shutil.copy(f'd1/{f}', f'{od}/{f}')
shutil.copy('wei2018_stage2_d1.png', f'{od}/wei2018_stage2_d1.png')
