import box2D.collision.B2Manifold;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.contacts.B2Contact;

/**
 * The library's tests. Run with `bash test/run.sh`; exits non-zero when a check fails.
 */
class TestMain
{
	static var failures:Int = 0;
	static var checks:Int = 0;

	static function main():Void
	{
		testNoScalesSwapsVelocities();
		testUnitScalesMatchNoScales();
		testOneSidedContact();
		testBothScalesZero();
		testOneSidedBoxes();
		testZeroScalesDropCachedImpulses();
		testScalesResetBeforePreSolve();

		Sys.println('$checks checks, $failures failed');
		Sys.exit(failures == 0 ? 0 : 1);
	}

	static function check(name:String, ok:Bool, ?detail:String):Void
	{
		checks++;
		if (!ok)
		{
			failures++;
			Sys.println('FAIL $name' + (detail != null ? ': $detail' : ''));
		}
	}

	static function near(name:String, actual:Float, expected:Float, tolerance:Float = 1e-6):Void
	{
		check(name, Math.abs(actual - expected) <= tolerance, 'expected $expected, got $actual');
	}

	// Two equal circles without gravity or friction, perfectly elastic, moving toward each other along x.
	static function headOn(listener:B2ContactListener):{a:B2Body, b:B2Body}
	{
		var world = new B2World(new B2Vec2(0, 0), false);
		if (listener != null)
		{
			world.setContactListener(listener);
		}
		var a = createBall(world, -1, 1);
		var b = createBall(world, 1, -1);
		for (i in 0...120)
		{
			world.step(1 / 60, 10, 8);
		}
		return {a: a, b: b};
	}

	static function createBall(world:B2World, x:Float, vx:Float):B2Body
	{
		var bodyDef = new B2BodyDef();
		bodyDef.type = DYNAMIC_BODY;
		bodyDef.position.set(x, 0);
		bodyDef.linearVelocity.set(vx, 0);
		var body = world.createBody(bodyDef);
		var fixtureDef = new B2FixtureDef();
		fixtureDef.shape = new B2CircleShape(0.5);
		fixtureDef.density = 1;
		fixtureDef.friction = 0;
		fixtureDef.restitution = 1;
		body.createFixture(fixtureDef);
		return body;
	}

	static function testNoScalesSwapsVelocities():Void
	{
		var r = headOn(null);
		near("no scales: A bounces back", r.a.getLinearVelocity().x, -1);
		near("no scales: B bounces back", r.b.getLinearVelocity().x, 1);
	}

	static function testUnitScalesMatchNoScales():Void
	{
		var plain = headOn(null);
		var unit = headOn(new ScalesListener(1, 1));
		check("unit scales: A as without scales", unit.a.getPosition().x == plain.a.getPosition().x
			&& unit.a.getLinearVelocity().x == plain.a.getLinearVelocity().x);
		check("unit scales: B as without scales", unit.b.getPosition().x == plain.b.getPosition().x
			&& unit.b.getLinearVelocity().x == plain.b.getLinearVelocity().x);
	}

	static function testOneSidedContact():Void
	{
		var listener = new ScalesListener(0, 1);
		var r = headOn(listener);
		check("one-sided: the contact was solved", listener.calls > 0);
		// A pushes B and is not pushed back: its velocity is unchanged.
		near("one-sided: A velocity x unchanged", r.a.getLinearVelocity().x, 1, 1e-12);
		near("one-sided: A velocity y unchanged", r.a.getLinearVelocity().y, 0, 1e-12);
		near("one-sided: A does not spin", r.a.getAngularVelocity(), 0, 1e-12);
		// B bounces off A as off an infinitely heavy wall moving at 1: relative speed 2 is reversed.
		near("one-sided: B bounces off A as off a wall", r.b.getLinearVelocity().x, 3);
		check("one-sided: B is ahead of A", r.b.getPosition().x > r.a.getPosition().x);
	}

	static function testBothScalesZero():Void
	{
		var r = headOn(new ScalesListener(0, 0));
		var vA = r.a.getLinearVelocity().x;
		var vB = r.b.getLinearVelocity().x;
		check("both zero: no NaN", !Math.isNaN(vA) && !Math.isNaN(vB) && !Math.isNaN(r.a.getPosition().x)
			&& !Math.isNaN(r.b.getPosition().x));
		near("both zero: A velocity unchanged", vA, 1, 1e-12);
		near("both zero: B velocity unchanged", vB, -1, 1e-12);
	}

	// Two boxes meeting face to face, slightly off-centre and turned: a two-point manifold, solved by the block solver.
	static function testOneSidedBoxes():Void
	{
		var world = new B2World(new B2Vec2(0, 0), false);
		var listener = new ScalesListener(0, 1);
		world.setContactListener(listener);
		var a = createBox(world, -1, 0, 0.02, 1);
		var b = createBox(world, 1, 0.2, -0.02, -1);
		var twoPoints = false;
		for (i in 0...120)
		{
			world.step(1 / 60, 10, 8);
			var c = world.getContactList();
			while (c != null)
			{
				twoPoints = twoPoints || (c.isTouching() && c.getManifold().m_pointCount == 2);
				c = c.getNext();
			}
		}
		check("one-sided boxes: the manifold had two points", twoPoints);
		near("one-sided boxes: A velocity x unchanged", a.getLinearVelocity().x, 1, 1e-12);
		near("one-sided boxes: A velocity y unchanged", a.getLinearVelocity().y, 0, 1e-12);
		near("one-sided boxes: A does not spin", a.getAngularVelocity(), 0, 1e-12);
		near("one-sided boxes: A angle unchanged", a.getAngle(), 0.02, 1e-12);
		check("one-sided boxes: B bounced off A", b.getLinearVelocity().x > 1, 'got ${b.getLinearVelocity().x}');
	}

	// A ball resting on the ground accumulates a contact impulse; once both scales become 0 the contact reports none.
	static function testZeroScalesDropCachedImpulses():Void
	{
		var world = new B2World(new B2Vec2(0, 10), false);
		var listener = new SwitchToZeroListener();
		world.setContactListener(listener);
		var ground = world.createBody(new B2BodyDef());
		var groundShape = new B2PolygonShape();
		groundShape.setAsBox(5, 0.5);
		var groundFixture = new B2FixtureDef();
		groundFixture.shape = groundShape;
		ground.createFixture(groundFixture);
		createBall(world, 0, 0);
		ground.setPositionAndAngle(new B2Vec2(0, 1), 0);
		for (i in 0...60)
		{
			world.step(1 / 60, 10, 8);
		}
		check("cached impulses: the resting contact pushed", listener.maxImpulse > 0);
		listener.zero = true;
		listener.maxImpulse = 0;
		listener.reports = 0;
		world.step(1 / 60, 10, 8);
		check("cached impulses: the contact was still reported", listener.reports > 0);
		near("cached impulses: zero scales report no impulse", listener.maxImpulse, 0, 0);
	}

	static function createBox(world:B2World, x:Float, y:Float, angle:Float, vx:Float):B2Body
	{
		var bodyDef = new B2BodyDef();
		bodyDef.type = DYNAMIC_BODY;
		bodyDef.position.set(x, y);
		bodyDef.angle = angle;
		bodyDef.linearVelocity.set(vx, 0);
		var body = world.createBody(bodyDef);
		var shape = new B2PolygonShape();
		shape.setAsBox(0.5, 0.5);
		var fixtureDef = new B2FixtureDef();
		fixtureDef.shape = shape;
		fixtureDef.density = 1;
		fixtureDef.friction = 0.5;
		fixtureDef.restitution = 0.5;
		body.createFixture(fixtureDef);
		return body;
	}

	static function testScalesResetBeforePreSolve():Void
	{
		var listener = new FirstStepOnlyListener();
		headOn(listener);
		check("reset: preSolve was called more than once", listener.seen.length > 1);
		var allUnit = true;
		for (s in listener.seen)
		{
			allUnit = allUnit && s == 1;
		}
		check("reset: every preSolve starts with scales 1", allUnit, 'seen ${listener.seen}');
	}
}

class ScalesListener extends B2ContactListener
{
	public var calls:Int = 0;

	var scaleA:Float;
	var scaleB:Float;

	public function new(scaleA:Float, scaleB:Float)
	{
		super();
		this.scaleA = scaleA;
		this.scaleB = scaleB;
	}

	override public function preSolve(contact:B2Contact, oldManifold:B2Manifold):Void
	{
		calls++;
		// Bodies are created A first, so the contact's body A is the left ball.
		if (contact.getFixtureA().getBody().getPosition().x < contact.getFixtureB().getBody().getPosition().x)
		{
			contact.setInvMassScales(scaleA, scaleB);
		}
		else
		{
			contact.setInvMassScales(scaleB, scaleA);
		}
	}
}

// Sets scale 0 on the first preSolve only and records both scales as every preSolve finds them.
class FirstStepOnlyListener extends B2ContactListener
{
	public var seen:Array<Float> = [];

	override public function preSolve(contact:B2Contact, oldManifold:B2Manifold):Void
	{
		seen.push(contact.getInvMassScaleA());
		seen.push(contact.getInvMassScaleB());
		if (seen.length == 2)
		{
			contact.setInvMassScales(0, 0);
		}
	}
}

// Sets both scales to 0 once `zero` is set; records the largest impulse postSolve reports.
class SwitchToZeroListener extends B2ContactListener
{
	public var zero:Bool = false;
	public var maxImpulse:Float = 0;
	public var reports:Int = 0;

	override public function preSolve(contact:B2Contact, oldManifold:B2Manifold):Void
	{
		if (zero)
		{
			contact.setInvMassScales(0, 0);
		}
	}

	override public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void
	{
		reports++;
		for (i in 0...contact.getManifold().m_pointCount)
		{
			maxImpulse = Math.max(maxImpulse, Math.max(Math.abs(impulse.normalImpulses[i]), Math.abs(impulse.tangentImpulses[i])));
		}
	}
}
