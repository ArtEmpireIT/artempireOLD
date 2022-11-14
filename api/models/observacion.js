/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('observacion', {
		id_observacion: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_observacion::regclass)",
			primaryKey: true
		},
		texto: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_documento: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		}
	}, {
		tableName: 'observacion',
		timestamps: false
	});
};
