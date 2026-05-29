import Matter from 'matter-js';

export interface ToyItem {
	id: string;
	emoji: string;
	name?: string;
	imageUrl?: string;
}

export type PhysicsMode = 'chaos' | 'water';

/** Collision radius — DOM size is exactly 2× this (no extra transparent hit area). */
export const TOY_RADIUS = 26;
export const TOY_DISPLAY_PX = TOY_RADIUS * 2;
export const TOY_EMOJI_PX = Math.round(TOY_DISPLAY_PX * 0.88);

/** Tuned for slower, calmer chaos play. */
const CHAOS = {
	gravityScale: 0.00082,
	restitution: 0.5,
	frictionAir: 0.026,
	spawnSpin: 0.1,
	spawnForceX: 0.0018,
	spawnForceYMin: 0.0006,
	spawnForceYRange: 0.0012,
	throwForceX: 0.004,
	throwForceYMin: 0.0012,
	throwForceYRange: 0.002,
	throwSpin: 0.1,
	collisionSpin: 0.08,
	maxAngularSpeed: 0.38,
	mouseStiffness: 0.14,
	mouseDamping: 0.16,
	wallRestitution: 0.32
} as const;

const WATER = {
	gravityScale: 0.001,
	restitution: 0.35,
	frictionAir: 0.04,
	/** < 1 so drinks are denser than water and sink to the bottom. */
	buoyancyFactor: 0.72,
	dragCoefficient: 0.055
} as const;

const WALL_THICKNESS = 48;
/** Ease-in water forces after chaos → water so the pile does not launch. */
const WATER_BLEND_MS = 750;

export interface DrinkPhysicsBoxOptions {
	onDoubleClick?: (id: string) => void;
	onSplash?: (x: number, y: number, velocityY: number) => void;
	mode?: PhysicsMode;
}

export class DrinkPhysicsBox {
	readonly engine: Matter.Engine;
	readonly world: Matter.World;
	readonly bodies = new Map<string, Matter.Body>();
	readonly elements = new Map<string, HTMLButtonElement>();
	private walls: Matter.Body[] = [];
	private mouseConstraint: Matter.MouseConstraint | null = null;
	private mouseInWorld = false;
	private mouse: Matter.Mouse | null = null;
	private width = 0;
	private height = 0;
	private raf = 0;
	private waterPercentage = 0.15;
	private mode: PhysicsMode = 'chaos';
	private resizeObserver: ResizeObserver | null = null;
	private collisionHandler: ((e: Matter.IEventCollision<Matter.Engine>) => void) | null = null;
	private endDragHandler: ((e: Matter.IEvent<Matter.MouseConstraint>) => void) | null = null;
	private beforeUpdateHandler: (() => void) | null = null;
	private documentPointerUpHandler: ((e: PointerEvent) => void) | null = null;
	private documentPointerMoveHandler: ((e: PointerEvent) => void) | null = null;
	private windowBlurHandler: (() => void) | null = null;
	private waterBlendStart = 0;

	constructor(
		private readonly container: HTMLElement,
		private readonly options?: DrinkPhysicsBoxOptions
	) {
		this.mode = options?.mode ?? 'chaos';
		if (this.mode === 'water') {
			this.waterBlendStart = performance.now();
		}
		this.engine = Matter.Engine.create({
			gravity: { x: 0, y: 1, scale: CHAOS.gravityScale }
		});
		this.world = this.engine.world;

		this.container.style.touchAction = 'none';
	}

	setMode(mode: PhysicsMode) {
		if (this.mode === mode) return;

		const enteringWater = mode === 'water' && this.mode === 'chaos';
		this.mode = mode;
		this.updateMouseConstraint();
		this.applyModeToBodies(enteringWater);
		this.updateWallRestitution();

		if (enteringWater) {
			this.waterBlendStart = performance.now();
		} else {
			this.waterBlendStart = 0;
		}
	}

	private applyModeToBodies(calming = false) {
		const chaos = this.mode === 'chaos';
		this.engine.gravity.scale = chaos ? CHAOS.gravityScale : WATER.gravityScale;

		for (const body of this.bodies.values()) {
			body.restitution = chaos ? CHAOS.restitution : WATER.restitution;
			body.frictionAir = chaos ? CHAOS.frictionAir : WATER.frictionAir;

			if (calming) {
				Matter.Body.setVelocity(body, {
					x: body.velocity.x * 0.2,
					y: body.velocity.y * 0.2
				});
				this.clampAngularVelocity(body, body.angularVelocity * 0.35);
			} else if (chaos) {
				this.clampAngularVelocity(body, body.angularVelocity * 0.65);
			} else {
				this.clampAngularVelocity(body, body.angularVelocity * 0.5);
			}
		}
	}

	private waterForceBlend(): number {
		if (this.mode !== 'water') return 0;
		if (this.waterBlendStart === 0) return 1;

		const t = Math.min(1, (performance.now() - this.waterBlendStart) / WATER_BLEND_MS);
		if (t >= 1) this.waterBlendStart = 0;
		// smoothstep
		return t * t * (3 - 2 * t);
	}

	private updateWallRestitution() {
		const restitution = this.mode === 'chaos' ? CHAOS.wallRestitution : 0.45;
		for (const wall of this.walls) {
			wall.restitution = restitution;
		}
	}

	setWaterPercentage(percentage: number) {
		this.waterPercentage = percentage;
	}

	setSize(width: number, height: number) {
		if (width < 80 || height < 80) return;
		this.width = width;
		this.height = height;
		this.rebuildWalls();
	}

	addToy(item: ToyItem) {
		if (this.bodies.has(item.id)) return;

		const el = document.createElement('button');
		el.type = 'button';
		el.className = 'physics-toy';
		el.style.width = `${TOY_DISPLAY_PX}px`;
		el.style.height = `${TOY_DISPLAY_PX}px`;

		if (item.imageUrl) {
			const img = document.createElement('img');
			img.src = item.imageUrl;
			img.alt = item.name ?? 'Drink';
			img.draggable = false;
			img.style.pointerEvents = 'none';
			img.style.width = '100%';
			img.style.height = '100%';
			img.style.objectFit = 'contain';
			el.appendChild(img);
		} else {
			const emoji = document.createElement('span');
			emoji.className = 'physics-toy-emoji';
			emoji.textContent = item.emoji;
			emoji.style.fontSize = `${TOY_EMOJI_PX}px`;
			el.appendChild(emoji);
		}

		el.title = item.name ?? 'Drink';
		el.setAttribute('aria-label', item.name ? `${item.name} drink toy` : 'Drink toy');
		this.container.appendChild(el);
		this.elements.set(item.id, el);

		el.addEventListener('dblclick', (e) => {
			e.preventDefault();
			this.options?.onDoubleClick?.(item.id);
		});

		const margin = TOY_RADIUS + 4;
		const x = margin + Math.random() * Math.max(1, this.width - margin * 2);
		const y = TOY_RADIUS + 8 + Math.random() * 18;

		const body = Matter.Bodies.circle(x, y, TOY_RADIUS, {
			restitution: this.mode === 'chaos' ? CHAOS.restitution : WATER.restitution,
			friction: 0.05,
			frictionAir: this.mode === 'chaos' ? CHAOS.frictionAir : WATER.frictionAir,
			frictionStatic: 0.1,
			density: 0.0022,
			label: item.id,
			angle: (Math.random() - 0.5) * Math.PI
		});

		if (this.mode === 'chaos') {
			this.clampAngularVelocity(body, (Math.random() - 0.5) * CHAOS.spawnSpin);
			Matter.Body.applyForce(body, body.position, {
				x: (Math.random() - 0.5) * CHAOS.spawnForceX,
				y: CHAOS.spawnForceYMin + Math.random() * CHAOS.spawnForceYRange
			});
		} else {
			Matter.Body.setVelocity(body, { x: 0, y: 1.2 + Math.random() * 0.8 });
		}

		Matter.Composite.add(this.world, body);
		this.bodies.set(item.id, body);
	}

	removeToy(id: string) {
		const body = this.bodies.get(id);
		const el = this.elements.get(id);
		if (body) {
			Matter.Composite.remove(this.world, body);
			this.bodies.delete(id);
		}
		if (el) {
			this.elements.delete(id);
			el.classList.add('popping');
			el.style.pointerEvents = 'none';

			const cleanup = () => {
				el.remove();
			};
			el.addEventListener('animationend', cleanup);
			setTimeout(cleanup, 300);
		}
	}

	syncItems(items: ToyItem[]) {
		const nextIds = new Set(items.map((i) => i.id));

		for (const id of this.bodies.keys()) {
			if (!nextIds.has(id)) this.removeToy(id);
		}

		for (const item of items) {
			if (!this.bodies.has(item.id)) this.addToy(item);
		}
	}

	start() {
		this.mouse = Matter.Mouse.create(this.container);
		this.mouse.pixelRatio = 1;

		this.mouseConstraint = Matter.MouseConstraint.create(this.engine, {
			mouse: this.mouse,
			constraint: {
				stiffness: CHAOS.mouseStiffness,
				damping: CHAOS.mouseDamping,
				render: { visible: false }
			}
		});
		this.updateMouseConstraint();
		this.bindDocumentPointerEvents();

		this.beforeUpdateHandler = () => this.syncMouseToContainer();
		Matter.Events.on(this.engine, 'beforeUpdate', this.beforeUpdateHandler);

		this.endDragHandler = (event) => {
			if (this.mode !== 'chaos') return;

			const body = event.source.body;
			if (!body || !this.bodies.has(body.label)) return;

			Matter.Body.applyForce(body, body.position, {
				x: (Math.random() - 0.5) * CHAOS.throwForceX,
				y: -(CHAOS.throwForceYMin + Math.random() * CHAOS.throwForceYRange)
			});
			this.addAngularVelocity(body, (Math.random() - 0.5) * CHAOS.throwSpin);
		};
		Matter.Events.on(this.mouseConstraint, 'enddrag', this.endDragHandler);

		this.collisionHandler = (event) => {
			if (this.mode !== 'chaos') return;

			for (const pair of event.pairs) {
				for (const part of [pair.bodyA, pair.bodyB]) {
					if (!this.bodies.has(part.label)) continue;
					if (Math.random() > 0.6) continue;
					this.addAngularVelocity(part, (Math.random() - 0.5) * CHAOS.collisionSpin);
				}
			}
		};
		Matter.Events.on(this.engine, 'collisionStart', this.collisionHandler);

		const loop = () => {
			Matter.Engine.update(this.engine, 1000 / 60);

			const surfaceY = this.waterSurfaceY();

			for (const [id, body] of this.bodies) {
				const el = this.elements.get(id);
				if (!el) continue;

				if (this.mode === 'water') {
					this.applyWaterForces(body, surfaceY);
					this.detectSplash(body, surfaceY);
				}

				const { x, y } = body.position;
				el.style.transform = `translate(${x}px, ${y}px) translate(-50%, -50%) rotate(${body.angle}rad)`;

				const isGrabbed = this.mouseConstraint?.body === body;
				el.classList.toggle('grabbed', isGrabbed);
			}

			this.raf = requestAnimationFrame(loop);
		};

		loop();

		this.resizeObserver = new ResizeObserver(() => {
			this.setSize(this.container.clientWidth, this.container.clientHeight);
		});
		this.resizeObserver.observe(this.container);
		this.setSize(this.container.clientWidth, this.container.clientHeight);
	}

	destroy() {
		cancelAnimationFrame(this.raf);
		this.resizeObserver?.disconnect();
		this.unbindDocumentPointerEvents();

		if (this.beforeUpdateHandler) {
			Matter.Events.off(this.engine, 'beforeUpdate', this.beforeUpdateHandler);
		}
		if (this.collisionHandler) {
			Matter.Events.off(this.engine, 'collisionStart', this.collisionHandler);
		}
		if (this.mouseConstraint && this.endDragHandler) {
			Matter.Events.off(this.mouseConstraint, 'enddrag', this.endDragHandler);
		}

		for (const id of [...this.bodies.keys()]) {
			this.removeToy(id);
		}

		if (this.mouseConstraint && this.mouseInWorld) {
			Matter.Composite.remove(this.world, this.mouseConstraint);
		}

		Matter.Engine.clear(this.engine);
	}

	/** Align Matter mouse coords with the playpen (fixes “ghost” grab/collision offset). */
	private syncMouseToContainer() {
		if (!this.mouse) return;

		const el = this.container;
		const rect = el.getBoundingClientRect();
		if (rect.width <= 0 || rect.height <= 0) return;

		this.mouse.scale.x = el.clientWidth / rect.width;
		this.mouse.scale.y = el.clientHeight / rect.height;
		this.mouse.pixelRatio = 1;
	}

	/** Matter only listens on the playpen — track/release drags at window level too. */
	private bindDocumentPointerEvents() {
		this.documentPointerUpHandler = () => this.releaseDragIfActive();
		this.documentPointerMoveHandler = (e) => this.trackPointerWhileDragging(e);
		this.windowBlurHandler = () => this.releaseDragIfActive();

		window.addEventListener('pointerup', this.documentPointerUpHandler);
		window.addEventListener('pointercancel', this.documentPointerUpHandler);
		window.addEventListener('pointermove', this.documentPointerMoveHandler);
		window.addEventListener('blur', this.windowBlurHandler);
	}

	private unbindDocumentPointerEvents() {
		if (this.documentPointerUpHandler) {
			window.removeEventListener('pointerup', this.documentPointerUpHandler);
			window.removeEventListener('pointercancel', this.documentPointerUpHandler);
		}
		if (this.documentPointerMoveHandler) {
			window.removeEventListener('pointermove', this.documentPointerMoveHandler);
		}
		if (this.windowBlurHandler) {
			window.removeEventListener('blur', this.windowBlurHandler);
		}
		this.documentPointerUpHandler = null;
		this.documentPointerMoveHandler = null;
		this.windowBlurHandler = null;
	}

	private trackPointerWhileDragging(e: PointerEvent) {
		if (!this.mouse || !this.mouseConstraint?.body) return;

		const rect = this.container.getBoundingClientRect();
		if (rect.width <= 0 || rect.height <= 0) return;

		this.mouse.position.x = (e.clientX - rect.left) * this.mouse.scale.x;
		this.mouse.position.y = (e.clientY - rect.top) * this.mouse.scale.y;
		this.mouse.absolute.x = e.clientX;
		this.mouse.absolute.y = e.clientY;
	}

	private releaseDragIfActive() {
		if (!this.mouseConstraint?.body) return;

		const body = this.mouseConstraint.body;
		Matter.Events.trigger(this.mouseConstraint, 'enddrag', {
			source: this.mouseConstraint,
			body
		});
		this.mouseConstraint.body = null;
		if (this.mouse) this.mouse.button = -1;
	}

	private waterSurfaceY() {
		return this.height - this.height * this.waterPercentage;
	}

	private circleBottomY(body: Matter.Body) {
		return body.position.y + TOY_RADIUS;
	}

	private updateMouseConstraint() {
		if (!this.mouseConstraint) return;

		if (this.mode === 'water') {
			this.mouseConstraint.body = null;
			if (this.mouseInWorld) {
				Matter.Composite.remove(this.world, this.mouseConstraint);
				this.mouseInWorld = false;
			}
			return;
		}

		if (!this.mouseInWorld) {
			Matter.Composite.add(this.world, this.mouseConstraint);
			this.mouseInWorld = true;
		}

		this.mouseConstraint.constraint.stiffness = CHAOS.mouseStiffness;
		this.mouseConstraint.constraint.damping = CHAOS.mouseDamping;
	}

	private maxAngularSpeed() {
		return this.mode === 'chaos' ? CHAOS.maxAngularSpeed : 0.5;
	}

	private clampAngularVelocity(body: Matter.Body, angularVelocity: number) {
		const max = this.maxAngularSpeed();
		Matter.Body.setAngularVelocity(
			body,
			Math.max(-max, Math.min(max, angularVelocity))
		);
	}

	private addAngularVelocity(body: Matter.Body, delta: number) {
		this.clampAngularVelocity(body, body.angularVelocity + delta);
	}

	/** Buoyancy when the circle actually enters the water, not when its center does. */
	private applyWaterForces(body: Matter.Body, surfaceY: number) {
		const blend = this.waterForceBlend();
		if (blend <= 0) return;

		const bottomY = this.circleBottomY(body);
		if (bottomY <= surfaceY) return;

		const submergedDepth = bottomY - surfaceY;
		const submergedRatio = Math.min(1, submergedDepth / (TOY_RADIUS * 2)) * blend;
		const gravityY = this.engine.gravity.y * (this.engine.gravity.scale ?? 0.0012);
		const buoyancyForce =
			-body.mass * gravityY * submergedRatio * WATER.buoyancyFactor;

		Matter.Body.applyForce(body, body.position, { x: 0, y: buoyancyForce });

		Matter.Body.applyForce(body, body.position, {
			x: -body.velocity.x * WATER.dragCoefficient * submergedRatio,
			y: -body.velocity.y * WATER.dragCoefficient * submergedRatio
		});

		const angularDamping = 1 - (0.08 + 0.04 * (1 - blend)) * submergedRatio;
		Matter.Body.setAngularVelocity(body, body.angularVelocity * angularDamping);

		const driftForceX =
			Math.sin(Date.now() * 0.0015 + body.id) * 0.00008 * submergedRatio * body.mass;
		Matter.Body.applyForce(body, body.position, { x: driftForceX, y: 0 });
	}

	private detectSplash(body: Matter.Body, surfaceY: number) {
		if (this.waterForceBlend() < 0.85) return;

		const prev = (body as Matter.Body & { positionPrev?: Matter.Vector }).positionPrev;
		if (!prev) return;

		const prevBottomY = prev.y + TOY_RADIUS;
		const bottomY = this.circleBottomY(body);
		const wasAbove = prevBottomY <= surfaceY;
		const isBelow = bottomY > surfaceY;
		if (wasAbove && isBelow && body.velocity.y > 0.35) {
			this.options?.onSplash?.(body.position.x, surfaceY, body.velocity.y);
		}
	}

	/** Walls flush with the visible playpen edges (no invisible inset box). */
	private rebuildWalls() {
		if (this.walls.length) {
			Matter.Composite.remove(this.world, this.walls);
			this.walls = [];
		}

		const { width: w, height: h } = this;
		const t = WALL_THICKNESS;
		const wall = {
			isStatic: true,
			friction: 0.22,
			restitution: this.mode === 'chaos' ? CHAOS.wallRestitution : 0.45
		};

		this.walls = [
			Matter.Bodies.rectangle(w / 2, h + t / 2, w + t * 2, t, wall),
			Matter.Bodies.rectangle(-t / 2, h / 2, t, h + t * 2, wall),
			Matter.Bodies.rectangle(w + t / 2, h / 2, t, h + t * 2, wall),
			Matter.Bodies.rectangle(w / 2, -t / 2, w + t * 2, t, wall)
		];

		Matter.Composite.add(this.world, this.walls);
		this.updateWallRestitution();
	}
}
