/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('transporte_rel_objeto', {
		fk_transporte_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'transporte',
				key: 'id_transporte'
			}
		},
		fk_objeto_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'objeto',
				key: 'id_objeto'
			}
		}
	}, {
		tableName: 'transporte_rel_objeto',
		timestamps: false
	});
};
