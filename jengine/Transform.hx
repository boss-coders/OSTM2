package jengine;

class Transform extends Component {
    public var pos :Vec2;

    public function new(?pos_ :Vec2) {
        pos = (pos_ != null) ? pos_ : new Vec2();
    }
}
