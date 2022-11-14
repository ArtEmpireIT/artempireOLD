/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('point', {
		geom_wgs84: {
			type: DataTypes.ENUM(),
			allowNull: true
		},
		id_point: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_point::regclass)",
			primaryKey: true
		},
		geom_nad27: {
			type: DataTypes.ENUM(),
			allowNull: true
		}
	}, {
		tableName: 'point',
		timestamps: false
	});
};
