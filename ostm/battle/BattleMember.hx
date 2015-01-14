package ostm.battle;

import js.html.Element;

import jengine.Entity;
import jengine.SaveManager;

import ostm.item.Affix;
import ostm.item.Item;
import ostm.item.ItemType;

class BattleMember implements Saveable {
    public var saveId(default, null) :String;

    public var entity :Entity;
    public var elem :Element;
    public var isPlayer(default, null) :Bool;

    public var equipment = new Map<ItemSlot, Item>();

    public var level :Int;
    public var attackSpeed :Float;
    public var baseHealth :Int;
    public var baseDamage :Int;
    public var baseDefense :Int;

    public var xp :Int = 0;
    public var health :Int = 0;
    public var healthPartial :Float = 0;
    public var attackTimer :Float = 0;

    public function new(isPlayer :Bool) {
        for (k in ItemSlot.createAll()) {
            equipment[k] = null;
        }

        this.isPlayer = isPlayer;
        if (this.isPlayer) {
            this.saveId = 'player';
            SaveManager.instance.addItem(this);
        }
    }

    public function addXp(xp :Int) :Void {
        this.xp += xp;
        var tnl = xpToNextLevel();
        if (this.xp >= tnl) {
            this.xp -= tnl;
            level++;
        }
    }
    public function xpToNextLevel() :Int {
        return 10 + 5 * (level - 1);
    }
    public function xpReward() :Int {
        return level + 2;
    }

    function scaleStat(base :Int, scale :Float) :Int {
        return Math.round(base * (1 + (level - 1) * scale));
    }
    function sumAffixes() :AffixModifier {
        var mod = new AffixModifier();
        for (item in equipment) {
            if (item != null) {
                item.sumAffixes(mod);
            }
        }
        return mod;
    }
    public function maxHealth() :Int {
        var mod = sumAffixes();
        var hp = scaleStat(baseHealth, 0.15);
        hp += mod.flatHealth;
        hp = Math.floor(hp * (1 + mod.percentHealth / 100));
        return hp;
    }
    public function damage() :Int {
        var damage = scaleStat(baseDamage, 0.17);
        for (item in equipment) {
            damage += item != null ? item.attack() : 0;
        }
        return damage;
    }
    public function defense() :Int {
        var defense = scaleStat(baseDefense, 0.12);
        for (item in equipment) {
            defense += item != null ? item.defense() : 0;
        }
        return defense;
    }
    public function healthRegen() :Float {
        return maxHealth() * 0.015;
    }

    public function equip(item :Item) :Void {
        equipment[item.type.slot] = item;
    }
    public function unequip(item :Item) :Void {
        equipment[item.type.slot] = null;
    }

    public function serialize() :Dynamic {
        var equips = [];
        for (item in equipment) {
            if (item != null) {
                equips.push(item.serialize());
            }
        }
        return {
            xp: this.xp,
            level: this.level,
            health: this.health,
            equipment: equips,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        xp = data.xp;
        level = data.level;
        health = data.health;
        if (data.equipment != null) {
            for (k in equipment.keys()) {
                equipment[k] = null;
            }
            var equips :Array<Dynamic> = data.equipment;
            for (d in equips) {
                var item = Item.loadItem(d);
                equipment[item.type.slot] = item;
            }
        }
    }
}
