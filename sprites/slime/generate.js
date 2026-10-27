// Writes src/<anim>_<dir>.txt for S, SE, E, NE, N (W/SW/NW are horizontal flips done in the engine).
// Poses are drawn once without eyes; each direction stamps its own eyes, so a pose fix reaches every direction.
// Usage: node sprites/slime/generate.js   (then run tools/build.ps1)
const fs = require('fs');
const SRC = process.argv[2] || `${__dirname}/src`;

// Eyeless poses: [first row, rows...]
const P = {
  B: [4, '......OOOO......', '....OOLLMMOO....', '...OLWLMMMMMO...', '..OLWLMMMMMMMO..', '..OLLMMMMMMMMO..', '.OMMMMMMMMMMMDO.', '.OMMMMMMMMMMMDO.', '.OMMMMMMMMMMMDO.', '.ODMMMMMMMMMDDO.', '.ODDDDDDDDDDDDO.', '..OOOOOOOOOOOO..'],
  Q: [5, '.....OOOOOO.....', '...OOLLMMMMOO...', '..OLWLMMMMMMMO..', '.OLWLMMMMMMMMMO.', '.OLLMMMMMMMMMDO.', 'OMMMMMMMMMMMMMDO', 'OMMMMMMMMMMMMMDO', 'ODMMMMMMMMMMMDDO', 'ODDDDDDDDDDDDDDO', '.OOOOOOOOOOOOOO.'],
  T: [3, '......OOOO......', '.....OLLMMO.....', '....OLWLMMMO....', '...OLWLMMMMMO...', '...OLLMMMMMMO...', '..OMMMMMMMMMDO..', '..OMMMMMMMMMDO..', '..OMMMMMMMMMDO..', '..OMMMMMMMMMDO..', '..ODMMMMMMMDDO..', '..ODDDDDDDDDDO..', '...OOOOOOOOOO...'],
  LS: [2, '.......OOOO.....', '......OLLMMO....', '.....OLWLMMMO...', '....OLWLMMMMMO..', '...OLLMMMMMMMO..', '..OMMMMMMMMMMO..', '..OMMMMMMMMMMO..', '..OMMMMMMMMMDO..', '..OMMMMMMMMMDO..', '..ODMMMMMMMDDO..', '..ODDDDDDDDDDO..', '...OOOOOOOOOO...'],
  AB: [5, '.....OOOO.......', '...OOLLMMOO.....', '..OLWLMMMMMO....', '.OLWLMMMMMMMO...', 'OMMMMMMMMMMMDO..', 'OMMMMMMMMMMMDO..', 'OMMMMMMMMMMMDO..', 'ODMMMMMMMMMDDO..', 'ODDDDDDDDDDDDO..', '.OOOOOOOOOOOO...'],
  FL: [9, '....OOOOOOOO....', '..OOLLMMMMMMOO..', '.OLWLMMMMMMMMDO.', 'OMMMMMMMMMMMMMDO', 'ODDDDDDDDDDDDDDO', '.OOOOOOOOOOOOOO.'],
  PD: [11, '...OOOOOOOOOO...', '.OOLLMMMMMMMMOO.', 'ODDDDDDDDDDDDDDO', '.OOOOOOOOOOOOOO.'],
  PR: [12, '....OOOOOOOO....', '..OODDDDDDDDOO..', '...OOOOOOOOOO...'],
  LG: [6, '........OOOO....', '......OOLLMMO...', '....OOLWLMMMMO..', '..OOLWLMMMMMMMO.', '.OMMMMMMMMMMMMMO', '.OMMMMMMMMMMMMMO', '.OMMMMMMMMMMMMDO', '.ODDDDDDDDDDDDDO', '..OOOOOOOOOOOOO.'],
};
const plus = (cx, cy) => [[cx, cy - 1], [cx - 1, cy], [cx, cy], [cx + 1, cy], [cx, cy + 1]];

// Frame: [pose, dy, eyes {l, r, y} or null, durationMs, spark center or null]
// Side family (SE/E/NE) eyes are given in SE coordinates; front family (S/N) in S coordinates.
const side = {
  idle: [['B', 0, { l: 6, r: 11, y: 9 }, 200], ['Q', 0, { l: 6, r: 11, y: 10 }, 150], ['B', 0, { l: 6, r: 11, y: 9 }, 200], ['T', 0, { l: 6, r: 11, y: 8 }, 150]],
  move: [['Q', 0, { l: 6, r: 11, y: 10 }, 120], ['LS', 0, { l: 6, r: 11, y: 7 }, 100], ['B', -2, { l: 6, r: 11, y: 7 }, 120], ['B', 0, { l: 6, r: 11, y: 9 }, 100]],
  attack: [['AB', 0, { l: 5, r: 10, y: 9 }, 150], ['LG', 0, { l: 9, r: 13, y: 10 }, 60], ['LG', 0, { l: 9, r: 13, y: 10 }, 100, [14, 7]], ['B', 0, { l: 6, r: 11, y: 9 }, 150]],
};
const front = {
  idle: [['B', 0, { l: 5, r: 10, y: 9 }, 200], ['Q', 0, { l: 5, r: 10, y: 10 }, 150], ['B', 0, { l: 5, r: 10, y: 9 }, 200], ['T', 0, { l: 5, r: 10, y: 8 }, 150]],
  move: [['Q', 0, { l: 5, r: 10, y: 10 }, 120], ['T', -1, { l: 5, r: 10, y: 7 }, 100], ['B', -2, { l: 5, r: 10, y: 7 }, 120], ['B', 0, { l: 5, r: 10, y: 9 }, 100]],
  attackS: [['T', 0, { l: 5, r: 10, y: 8 }, 150], ['Q', 1, { l: 5, r: 10, y: 11 }, 60], ['Q', 1, { l: 5, r: 10, y: 11 }, 100, [13, 3]], ['B', 0, { l: 5, r: 10, y: 9 }, 150]],
  attackN: [['Q', 0, null, 150], ['T', -1, null, 60], ['T', -1, null, 100, [12, 1]], ['B', 0, null, 150]],
};

// Death: hit flash, closed-eye squash, melt, puddle, held remnant. Same poses for every direction.
const death = e => [['T', 0, { ...e, y: 8 }, 80, null, 'flash'], ['Q', 0, { ...e, y: 10, closed: true }, 120], ['FL', 0, { ...e, y: 12, closed: true }, 150], ['PD', 0, null, 200], ['PR', 0, null, 600]];
side.death = death({ l: 6, r: 11 });
front.death = death({ l: 5, r: 10 });

// Which eyes each direction shows, as [x, height]: open eyes are vertical, closed ones a horizontal dash pointing outward.
const eyesFor = {
  S: e => [[e.l, 2], [e.r, 2]],
  SE: e => [[e.l, 2], [e.r, 2]],
  E: e => [[e.r, 2]],     // profile: one eye at the front (r+1 merges with the shade/outline)
  NE: e => [[e.r + 1, 1]], // turning away: only a sliver of the front eye
  N: () => [],
};
const eyePixels = (e, dir) => eyesFor[dir](e).flatMap(([x, h]) =>
  e.closed ? (h === 1 ? [[x, e.y]] : [[x, e.y], [x < 8 ? x - 1 : x + 1, e.y]])
           : (h === 1 ? [[x, e.y]] : [[x, e.y], [x, e.y + 1]]));

function frame([pose, dy, eyes, ms, spark, fx], dir, label) {
  const [top, ...rows] = P[pose];
  const g = Array.from({ length: 16 }, () => [...'.'.repeat(16)]);
  rows.forEach((r, i) => { const y = top + i + dy; if (y < 0 || y > 15) throw label + ': pose off canvas'; g[y] = [...r]; });
  if (fx === 'flash') for (const r of g) r.forEach((c, x) => { if ('LMD'.includes(c)) r[x] = 'W'; });
  for (const [x, y] of eyes ? eyePixels(eyes, dir) : []) {
    if (fx === 'flash' && g[y][x] === 'W') { g[y][x] = 'O'; continue; }
    if (!'MDL'.includes(g[y][x])) throw `${label}: eye at ${x},${y} lands on '${g[y][x]}'`;
    g[y][x] = 'O';
  }
  for (const [x, y] of spark ? plus(...spark) : []) {
    if (g[y][x] !== '.') throw `${label}: spark at ${x},${y} overlaps body`;
    g[y][x] = 'W';
  }
  return `---- ${ms}\n` + g.map(r => r.join('')).join('\n');
}

const plan = {
  S: { idle: front.idle, move: front.move, attack: front.attackS, death: front.death },
  SE: side, E: side, NE: side,
  N: { idle: front.idle, move: front.move, attack: front.attackN, death: front.death },
};
for (const [dir, anims] of Object.entries(plan))
  for (const [anim, frames] of Object.entries(anims)) {
    const name = `${anim}_${dir.toLowerCase()}`;
    fs.writeFileSync(`${SRC}/${name}.txt`, frames.map((f, i) => frame(f, dir, `${name} f${i + 1}`)).join('\n') + '\n');
  }
console.log('ok');
