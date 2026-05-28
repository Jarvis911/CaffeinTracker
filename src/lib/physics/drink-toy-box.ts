import Matter from 'matter-js';

export interface ToyItem {
	id: string;
	emoji: string;
	name?: string;
}

const TOY_RADIUS = 26;

export class DrinkPhysicsBox {
	readonly engine: Matter.Engine;
	readonly world: Matter.World;
	readonly bodies = new Map<string, Matter.Body>();
	readonly elements = new Map<string, HTMLButtonElement>();
	private walls: Matter.Body[] = [];
	private mouseConstraint: Matter.MouseConstraint | null = null;
	private mouse: Matter.Mouse | null = null;
	private width = 0;
	private height = 0;
	private raf = 0;
	private resizeObserver: ResizeObserver | null = null;
	private collisionHandler: ((e: Matter.IEventCollision<Matter.Engine>) => void) | null = null;
	private endDragHandler: ((e: Matter.IEvent<Matter.MouseConstraint>) => void) | null = null;

	constructor(private readonly container: HTMLElement) {
		this.engine = Matter.Engine.create({
			gravity: { x: 0, y: 1, scale: 0.0012 }
		});
		this.world = this.engine.world;

		this.container.style.touchAction = 'none';
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
		el.textContent = item.emoji;
		el.title = item.name ?? 'Drink';
		el.setAttribute('aria-label', item.name ? `${item.name} drink toy` : 'Drink toy');
		this.container.appendChild(el);
		this.elements.set(item.id, el);

		const margin = TOY_RADIUS + 4;
		const x = margin + Math.random() * Math.max(1, this.width - margin * 2);
		const y = TOY_RADIUS + 8 + Math.random() * 36;

		const body = Matter.Bodies.circle(x, y, TOY_RADIUS, {
			restitution: 0.78,
			friction: 0.04,
			frictionAir: 0.012,
			frictionStatic: 0.1,
			density: 0.0022,
			label: item.id,
			angle: (Math.random() - 0.5) * Math.PI
		});

		Matter.Body.setAngularVelocity(body, (Math.random() - 0.5) * 0.35);
		Matter.Body.applyForce(body, body.position, {
			x: (Math.random() - 0.5) * 0.006,
			y: 0.002 + Math.random() * 0.004
		});

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
			el.remove();
			this.elements.delete(id);
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
		this.mouseConstraint = Matter.MouseConstraint.create(this.engine, {
			mouse: this.mouse,
			constraint: {
				stiffness: 0.18,
				damping: 0.08,
				render: { visible: false }
			}
		});
		Matter.Composite.add(this.world, this.mouseConstraint);

		this.endDragHandler = (event) => {
			const body = event.source.body;
			if (!body || !this.bodies.has(body.label)) return;

			Matter.Body.applyForce(body, body.position, {
				x: (Math.random() - 0.5) * 0.012,
				y: -0.004 - Math.random() * 0.006
			});
			Matter.Body.setAngularVelocity(
				body,
				body.angularVelocity + (Math.random() - 0.5) * 0.4
			);
		};
		Matter.Events.on(this.mouseConstraint, 'enddrag', this.endDragHandler);

		this.collisionHandler = (event) => {
			for (const pair of event.pairs) {
				for (const part of [pair.bodyA, pair.bodyB]) {
					if (!this.bodies.has(part.label)) continue;
					if (Math.random() > 0.55) continue;
					Matter.Body.setAngularVelocity(
						part,
						part.angularVelocity + (Math.random() - 0.5) * 0.22
					);
				}
			}
		};
		Matter.Events.on(this.engine, 'collisionStart', this.collisionHandler);

		const loop = () => {
			Matter.Engine.update(this.engine, 1000 / 60);

			for (const [id, body] of this.bodies) {
				const el = this.elements.get(id);
				if (!el) continue;

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

		if (this.collisionHandler) {
			Matter.Events.off(this.engine, 'collisionStart', this.collisionHandler);
		}
		if (this.mouseConstraint && this.endDragHandler) {
			Matter.Events.off(this.mouseConstraint, 'enddrag', this.endDragHandler);
		}

		for (const id of [...this.bodies.keys()]) {
			this.removeToy(id);
		}

		if (this.mouseConstraint) {
			Matter.Composite.remove(this.world, this.mouseConstraint);
		}

		Matter.Engine.clear(this.engine);
	}

	private rebuildWalls() {
		if (this.walls.length) {
			Matter.Composite.remove(this.world, this.walls);
			this.walls = [];
		}

		const { width: w, height: h } = this;
		const t = 48;
		const wall = { isStatic: true, friction: 0.2, restitution: 0.55 };

		this.walls = [
			Matter.Bodies.rectangle(w / 2, h + t / 2 - 6, w + t * 2, t, wall),
			Matter.Bodies.rectangle(-t / 2 + 6, h / 2, t, h + t, wall),
			Matter.Bodies.rectangle(w + t / 2 - 6, h / 2, t, h + t, wall),
			Matter.Bodies.rectangle(w / 2, -t / 2 + 10, w + t * 2, t, wall)
		];

		Matter.Composite.add(this.world, this.walls);
	}
}
